package org.daisy.pipeline.tts.filibuster;

import java.io.File;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.sound.sampled.AudioFormat;
import net.sf.saxon.s9api.XdmNode;

import org.daisy.pipeline.audio.AudioBuffer;
import org.daisy.pipeline.tts.AudioBufferAllocator;
import org.daisy.pipeline.tts.AudioBufferAllocator.MemoryException;
import org.daisy.pipeline.tts.TTSEngine;
import org.daisy.pipeline.tts.TTSRegistry.TTSResource;
import org.daisy.pipeline.tts.TTSService.Mark;
import org.daisy.pipeline.tts.TTSService.SynthesisException;
import org.daisy.pipeline.tts.Voice;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class FilibusterEngine extends TTSEngine {
	private Logger logger = LoggerFactory.getLogger(FilibusterEngine.class);

	private AudioFormat audioFormat;
	private String[] cmd;
	private String[] env;
	private File filibusterPath;
	private int priority;
    
	private Map<FilibusterInstance, List<Thread>> filibusterInstances = Collections.synchronizedMap(new HashMap<FilibusterInstance, List<Thread>>());
	private static final int MAX_FILIBUSTER_INSTANCES;
	
	// set MAX_FILIBUSTER_INSTANCES based on environment variable FILIBUSTER_INSTANCES or system property filibuster.instances
	// default to 6 if neither is an integer
	static {
		int instances;
		String instancesString = System.getenv("FILIBUSTER_INSTANCES");
		try {
			instances = Integer.parseInt(instancesString);
		} catch (Exception e1) {
			instancesString = System.getProperty("filibuster.instances");
			try {
				instances = Integer.parseInt(instancesString);
			} catch (Exception e2) {
				instances = 6;
			}
		}
		MAX_FILIBUSTER_INSTANCES = instances > 0 ? instances : 1;
	}

	public FilibusterEngine(FilibusterService filibusterService, String filibusterPath, String tclshPath, int priority) {
		super(filibusterService);
		this.filibusterPath = new File(filibusterPath);
		this.priority = priority;
		this.cmd = new String[]{ tclshPath, "narraFil2.tcl", "no" };
		this.env = new String[]{ "USER=user" };
		
		this.audioFormat = new AudioFormat(AudioFormat.Encoding.PCM_SIGNED, 22050.0f, 16, 1, 2, 22050.0f, false);
	}
	
	public String threadId() {
		// for debugging
		return (Thread.currentThread().getId()+"").replaceAll("^.*(..)$", "$1")+": ";
	}
	
	@Override
	public int expectedMillisecPerWord() {
		return 5000;
	};
	
	@Override
	public int reservedThreadNum() {
		return MAX_FILIBUSTER_INSTANCES;
	};
	
	@Override
	public void interruptCurrentWork(TTSResource resource) {
		// ignore interrupt requests! this is a slow TTS...
	};

	@Override
	public Collection<AudioBuffer> synthesize(String sentence, XdmNode xmlSentence,
	        Voice voice, TTSResource threadResources, List<Mark> marks,
	        AudioBufferAllocator bufferAllocator, boolean retry) throws SynthesisException,
	        InterruptedException, MemoryException {
		
		if (threadResources instanceof FilibusterInstance) {
			logger.debug(threadId()+"synthesizing: '"+sentence+"'");
			return ((FilibusterInstance)threadResources).synthesize(sentence, bufferAllocator);
			
		} else {
			throw new SynthesisException("FilibusterEngine can only synthesize with a FilibusterInstance, not any other TTSResource");
		}
	}

	@Override
	public AudioFormat getAudioOutputFormat() {
		return audioFormat;
	}

	@Override
	public Collection<Voice> getAvailableVoices() {
		Collection<Voice> result = new ArrayList<Voice>();
		result.add(new Voice(getProvider().getName(), "Brage"));
		return result;
	}

	@Override
	public int getOverallPriority() {
		return priority;
	}

	@Override
	public synchronized TTSResource allocateThreadResources() throws SynthesisException, InterruptedException {
		
		for (FilibusterInstance instance : filibusterInstances.keySet()) {
			List<Thread> threadList = filibusterInstances.get(instance);
			if (threadList.contains(Thread.currentThread())) {
				return instance;
			}
		}
		
		if (filibusterInstances.size() < MAX_FILIBUSTER_INSTANCES) {
			FilibusterInstance instance = new FilibusterInstance(cmd, env, filibusterPath);
			List<Thread> threadList = new ArrayList<Thread>();
			threadList.add(Thread.currentThread());
			filibusterInstances.put(instance, threadList);
			return instance;
		}
		
		logger.debug(threadId()+"no room for more filibuster instances; reusing a filibuster instance");
		int minThreads = -1;
		FilibusterInstance instanceWithLeastThreads = null;
		for (FilibusterInstance instance : filibusterInstances.keySet()) {
			List<Thread> threadList = filibusterInstances.get(instance);
			if (minThreads < 0 || threadList.size() < minThreads) {
				minThreads = threadList.size();
				instanceWithLeastThreads = instance;
			}
		}
		filibusterInstances.get(instanceWithLeastThreads).add(Thread.currentThread());
		return instanceWithLeastThreads;
		
	}

	@Override
	public synchronized void releaseThreadResources(TTSResource resource) throws SynthesisException, InterruptedException {
		logger.debug(threadId()+"releaseThreadResources() -- got engine lock");
		
		List<Thread> threadList = null;
		FilibusterInstance instance = null;
		for (FilibusterInstance i : filibusterInstances.keySet()) {
			threadList = filibusterInstances.get(i);
			if (threadList.contains(Thread.currentThread())) {
				instance = i;
				break;
			}
		}
		
		if (threadList != null) {
			threadList.remove(Thread.currentThread());
			logger.debug(threadId()+"thread removed itself from filibuster instance");
			/*if (threadList.isEmpty()) {
				logger.debug(threadId()+"no more threads using this filibuster instance; stopping filibuster...");
				// Try stopping Filibuster
				instance.stopFilibuster(false);
				filibusterInstances.remove(instance);
			}*/
		}
		super.releaseThreadResources(resource);
		logger.debug(threadId()+"releaseThreadResources() -- released engine lock");
	}

}
