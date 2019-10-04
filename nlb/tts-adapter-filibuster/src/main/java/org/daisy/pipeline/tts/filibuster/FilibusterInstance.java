package org.daisy.pipeline.tts.filibuster;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import org.daisy.pipeline.audio.AudioBuffer;
import org.daisy.pipeline.tts.AudioBufferAllocator;
import org.daisy.pipeline.tts.SoundUtil;
import org.daisy.pipeline.tts.TTSRegistry.TTSResource;
import org.daisy.pipeline.tts.AudioBufferAllocator.MemoryException;
import org.daisy.pipeline.tts.TTSService.SynthesisException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class FilibusterInstance extends TTSResource {
	private Logger logger = LoggerFactory.getLogger(FilibusterInstance.class);
	
	private String currentSentence = null;
	private Map<Integer, Date> current = Collections.synchronizedMap(new HashMap<Integer, Date>());
	private int sentenceCount = 0;
	
	private String[] cmd;
	private String[] env;
	private File filibusterPath;

	private Process process = null;
	private BufferedOutputStream stdin = null;
	private BufferedInputStream stdout = null;
	
	private Date instanceStartTime = null;
	
	private final static int MIN_CHUNK_SIZE = 2048;

	public String threadId() {
		// for debugging
		return (Thread.currentThread().getId()+"").replaceAll("^.*(..)$", "$1")+": instance "+(this.hashCode()+"").replaceAll("^.*(..)$", "$1")+": ";
	}
	
	public FilibusterInstance(String[] cmd, String[] env, File filibusterPath) {
		this.cmd = cmd;
		this.env = env;
		this.filibusterPath = filibusterPath;
	}
	
	public synchronized void startFilibuster(boolean force) throws SynthesisException, InterruptedException {
		// Start Filibuster instance
		if (force || process == null || !process.isAlive()) {
			if (process != null && process.isAlive()) {
				logger.debug(threadId()+"filibuster is stopped, need to start it");
				stopFilibuster(true);
			}
			logger.debug(threadId()+"starting Filibuster instance...");
			try {
				process = Runtime.getRuntime().exec(cmd, env, filibusterPath);
				stdin = new BufferedOutputStream((process.getOutputStream()));
				stdout = new BufferedInputStream(process.getInputStream());
				instanceStartTime = new Date();
				logger.debug(threadId()+"instance started: "+process);

			} catch (Exception e) {
				StringWriter sw = new StringWriter();
				e.printStackTrace(new PrintWriter(sw));
				stopFilibuster(true);
				throw new SynthesisException(e);
			}
		} else logger.debug(threadId()+"filibuster is already running");
	}

	public void stopFilibuster(boolean ignoreQueuedSentences) throws SynthesisException, InterruptedException {
		while (current.size() > 0) {
			logger.debug(threadId()+"waiting 1s for all sentences to finish synthesizing...");
			Date mostRecent = null;
			for (Integer sentenceNr : current.keySet()) {
				Date startTime = current.get(sentenceNr);
				if (mostRecent == null || startTime.after(mostRecent)) {
					mostRecent = startTime;
				}
			}
			if (mostRecent.before(new Date(new Date().getTime() - 120000L))) {
				// more than two minutes since last sentence were started; kill the instance 
				break;
			}
			try {
				logger.debug(threadId()+"most recent instance was "+((new Date().getTime() - mostRecent.getTime()) / 1000L)+" seconds ago. Timeout will occur at 120s");
				Thread.sleep(1000L);
			} catch (InterruptedException e) {
				// yeah, I know it's bad to ignore this, but it works...
			}
		}
		
		logger.debug(threadId()+"stopping Filibuster instance...");
		synchronized (this) {
			if (currentSentence != null) {
				logger.warn(threadId()+"trying to stop Filibuster while synthesizing: '"+currentSentence+"'");
				for (StackTraceElement line : new Exception(threadId()+"trying to stop Filibuster while synthesizing: '"+currentSentence+"'").getStackTrace()) {
					logger.warn(threadId()+line.toString());
				}
			}
			try {
				if (stdin != null) {
					logger.debug(threadId()+"sending empty string to try and make filibuster shut down voluntarily");
					stdin.write("\n\n".getBytes("utf-8")); // send empty string to try and make filibuster shut down voluntarily
					logger.debug(threadId()+"closing stdin");
					stdin.close();
					logger.debug(threadId()+"closing stdout");
					stdout.close();
					logger.debug(threadId()+"done closing stdin and stdout");
				}
				if (process != null) {
					logger.debug(threadId()+"process != null");
					try {
						logger.debug(threadId()+"waiting for 1 second...");
						process.waitFor(1L, TimeUnit.SECONDS);
						logger.debug(threadId()+"done waiting for 1 second");
					} catch (NoSuchMethodError e) {
						// Thrown for some reason in a Java 7 environment. Might be something with that setup, not sure; In any case, it should be safe to ignore.
						logger.debug(threadId()+"failed waiting for 1 second: "+e.getMessage());
					}
					logger.debug(threadId()+"destroying filibuster process forcefully...");
					process.destroy();
					logger.debug(threadId()+"done destroying filibuster process forcefully");
				}
			} catch (InterruptedException e) {
				logger.debug(threadId()+e.getMessage());
				StringWriter sw = new StringWriter();
				e.printStackTrace(new PrintWriter(sw));
				if (process != null)
					process.destroy();
				throw e;
	
			} catch (Exception e) {
				logger.debug(threadId()+e.getMessage());
				StringWriter sw = new StringWriter();
				e.printStackTrace(new PrintWriter(sw));
				if (process != null)
					process.destroy();
				throw new SynthesisException(e);
			} finally {
				logger.debug(threadId()+"nullifying process, stdin and stdout");
				process = null;
				stdin = null;
				stdout = null;
			}
			logger.debug(threadId()+"nullifying instanceStartTime");
			instanceStartTime = null;
			logger.debug(threadId()+"Filibuster instance has been stopped.");
		}
	}
	
	public Collection<AudioBuffer> synthesize(String sentence, AudioBufferAllocator bufferAllocator) throws SynthesisException, MemoryException, InterruptedException {
		logger.debug(threadId()+"instance synthesize() -- got instance lock");
		Integer currentSentenceNr = sentenceCount++;
		current.put(currentSentenceNr, new Date());
		logger.debug(threadId()+"sentence number "+currentSentenceNr+" added ("+sentence+")");
		synchronized (this) {
			try {
				Date startTime = new Date();
		
				Collection<AudioBuffer> result = new ArrayList<AudioBuffer>();
		
				startFilibuster(false);
		
				try {
					// write the text
					logger.debug(threadId()+"writing the text to process "+process);
					stdin.write((sentence.replaceAll("\n", " ")+" \n").getBytes("utf-8"));
					logger.debug(threadId()+"flushing the text to process "+process);
					stdin.flush();
		
					// read the wave on the standard output
		
					/* debugging stuff */
					File file = null;
					FileOutputStream fos = null;
					String byteString = "";
					if (logger.isDebugEnabled()) {
						file = Files.createTempFile("out", ".wav").toFile();
						fos = new FileOutputStream(file);
					}
		
					int bytesAvailable = stdout.available();
					byte[] header = new byte[44];
					int headerPos = 0;
					int bytesRead = 0;
					int bytesExpected = header.length;
					Date timeout = new Date();
					AudioBuffer b = null;
					while (bytesAvailable > 0 || bytesRead + 1 < bytesExpected) {
						if (bytesAvailable <= 0) {
							if (new Date().getTime() - timeout.getTime() < 30000 || new Date().getTime() - instanceStartTime.getTime() < 60000) {
								logger.debug(threadId()+"sleeping 100ms to see if more data arrives...");
								try {
									Thread.sleep(100);
		
								} catch (InterruptedException e) {
									// thread interrupted, oh well, let's continue then...
								}
		
							} else {
								logger.debug(threadId()+"timeout");
								break;
							}
		
						} else {
							logger.debug(threadId()+"allocating buffer for "+bytesAvailable+" available bytes");
							b = bufferAllocator.allocateBuffer(MIN_CHUNK_SIZE + bytesAvailable);
							logger.debug(threadId()+"reading data into buffer of size '"+b.size+"': "+b+" ("+new Date()+")");
							int ret = stdout.read(b.data, 0, b.size);
							logger.debug(threadId()+"return value from stdout.read: "+ret);
							if (ret == -1) {
								logger.debug(threadId()+"end of stream reached");
								break;
							} else if (ret > 0) {
								logger.debug(threadId()+"Read bytes from process '"+process+"': "+ret+" ("+new Date()+")");
								timeout = new Date();
							}
		
							// store header in `header` and check expected file size.
							int headerBytesInBuffer = 0;
							for (int dataPos = 0; headerPos < header.length && dataPos < b.data.length; dataPos++) {
								header[headerPos] = b.data[dataPos];
								headerPos++;
								headerBytesInBuffer++;
							}
							if (bytesExpected == header.length && headerPos > 7) {
								ByteBuffer bb = ByteBuffer.wrap(new byte[]{header[4],header[5],header[6],header[7]});
								bb.order(ByteOrder.LITTLE_ENDIAN);
								bytesExpected = bb.getInt()+8;
							}
							bytesRead += ret;
							logger.debug(threadId()+"WAV file should be "+(bytesExpected == header.length ? "at least " : "")+bytesExpected+" bytes in size. "+bytesRead+" bytes have been read so far.");
		
							if (logger.isDebugEnabled()) {
								byteString += new String(b.data, "utf-8");
								fos.write(b.data);
							}
		
							int stripOverflowBytes = Math.max((bytesRead - bytesExpected), 0);
		
							if (ret - headerBytesInBuffer - stripOverflowBytes > 0) {
		
								// don't include header in result bytes
								if (headerBytesInBuffer > 0 || stripOverflowBytes > 0) {
									logger.debug(threadId()+"discarding "+headerBytesInBuffer+" header bytes and "+stripOverflowBytes+" overflow bytes.");
									b.data = Arrays.copyOfRange(b.data, headerBytesInBuffer, b.data.length - stripOverflowBytes);
									b.size = ret - headerBytesInBuffer - stripOverflowBytes;
		
								} else {
									b.size = ret;
								}
		
							} else if (headerBytesInBuffer > 0) {
								logger.debug(threadId()+"discarding "+headerBytesInBuffer+" header bytes and "+stripOverflowBytes+" overflow bytes; no real audio data remaining in buffer");
							}
		
							result.add(b);
		
						}
		
						try {
							bytesAvailable = stdout.available();
						} catch (IOException e) {
							logger.debug(threadId()+" stream closed");
							bytesAvailable = 0; // stream closed
						}
						if (bytesAvailable > 0) logger.debug(threadId()+bytesAvailable+" bytes available; continuing loop");
						else if (bytesRead < bytesExpected) logger.debug(threadId()+bytesRead+" bytes read but "+bytesExpected+" bytes expected; continuing loop");
					}
					if (b != null) {
						try {
							bufferAllocator.releaseBuffer(b);
		
						} catch (Exception e) {
							// probably safe to ignore
						}
					}
		
					/* debugging */
					if (logger.isDebugEnabled()) {
		//				for (byte bte : header) {
		//					logger.debug(threadId()+"header byte: "+new Byte(bte).intValue();
		//				}
						String badData = byteString.startsWith("RIFF") ? "(GOOD DATA)" : "(BAD DATA)";
						if (byteString.length() > header.length) {
							logger.debug(threadId()+badData+" header=["+byteString.substring(0, header.length)+"]");
						} else {
							logger.debug(threadId()+badData+" header=["+byteString+"]");
						}
						fos.close();
						logger.debug(threadId()+"wrote: "+file.getAbsolutePath());
					}
					if (fos != null) {
						try {
							fos.close();
						} catch (IOException e) {
							// `fos` is for debugging so any exception here should be safe to ignore
						}
					}
		
					// hopefully it's ok to not close audioStream ? Otherwise, how can I close the audioStream without closing the underlying stdout?
		
				} catch (MemoryException e) {
					SoundUtil.cancelFootPrint(result, bufferAllocator);
					process.destroy();
					currentSentence = null;
					current.remove(currentSentenceNr);
					logger.debug(threadId()+"sentence number "+currentSentenceNr+" removed ("+sentence+")");
					throw e;
		
				} catch (Exception e) {
					SoundUtil.cancelFootPrint(result, bufferAllocator);
					StringWriter sw = new StringWriter();
					e.printStackTrace(new PrintWriter(sw));
					if (process != null)
						process.destroy();
					currentSentence = null;
					current.remove(currentSentenceNr);
					logger.debug(threadId()+"sentence number "+currentSentenceNr+" removed ("+sentence+")");
					throw new SynthesisException(e);
				}
				logger.debug(threadId()+"done synthesizing: '"+sentence+"'");
				logger.debug(threadId()+"time spent: "+(new Date().getTime() - startTime.getTime())/1000L+"s");
				logger.debug(threadId()+"----------");
				currentSentence = null;
				current.remove(currentSentenceNr);
				logger.debug(threadId()+"sentence number "+currentSentenceNr+" removed ("+sentence+")");
				logger.debug(threadId()+"instance synthesize() -- returning (i.e. releasing instance lock)");
				return result;
				
			} catch (Exception e) {
				currentSentence = null;
				current.remove(currentSentenceNr);
				logger.debug(threadId()+"sentence number "+currentSentenceNr+" removed ("+sentence+")");
				throw e;
			}
		}
	}
}
