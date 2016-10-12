package org.daisy.pipeline.tts.filibuster;

import java.util.Collection;
import java.util.HashMap;
import org.daisy.pipeline.audio.AudioBuffer;
import org.daisy.pipeline.tts.AudioBufferAllocator;
import org.daisy.pipeline.tts.AudioBufferAllocator.MemoryException;
import org.daisy.pipeline.tts.StraightBufferAllocator;
import org.daisy.pipeline.tts.TTSRegistry.TTSResource;
import org.daisy.pipeline.tts.TTSService.SynthesisException;
import org.daisy.pipeline.tts.Voice;
import org.junit.Assert;
import org.junit.Test;

public class FilibusterTest {

	static AudioBufferAllocator BufferAllocator = new StraightBufferAllocator();

	private static int getSize(Collection<AudioBuffer> buffers) {
		int res = 0;
		for (AudioBuffer buf : buffers) {
			res += buf.size;
		}
		return res;
	}

	private static FilibusterEngine allocateEngine() throws Throwable {
		FilibusterService s = new FilibusterService();
		return (FilibusterEngine) s.newEngine(new HashMap<String, String>());
	}

	private static Voice getAnyVoice(FilibusterEngine engine) throws SynthesisException,
	        InterruptedException {
		return engine.getAvailableVoices().iterator().next();
	}

	@Test
	public void getVoiceInfo() throws Throwable {
		Collection<Voice> voices = allocateEngine().getAvailableVoices();
		Assert.assertTrue(voices.size() >= 1);
	}

	@Test
	public void speakEasy() throws Throwable {
		FilibusterEngine engine = allocateEngine();
		Voice voice = getAnyVoice(engine);

		TTSResource resource = engine.allocateThreadResources();
		Collection<AudioBuffer> audio1 = engine.synthesize("this is a test", null, voice, resource,  null, BufferAllocator, false);
		Collection<AudioBuffer> audio2 = engine.synthesize("this is another test", null, voice, resource,  null, BufferAllocator, false);
		Collection<AudioBuffer> audio3 = engine.synthesize("this is a third test", null, voice, resource,  null, BufferAllocator, false);
		engine.releaseThreadResources(resource);
		
		Assert.assertTrue(getSize(audio1) > 2000);
		Assert.assertTrue(getSize(audio2) > 2000);
		Assert.assertTrue(getSize(audio3) > 2000);
	}

	@Test
	public void speakUnicode() throws Throwable {
		FilibusterEngine engine = allocateEngine();
		TTSResource resource = engine.allocateThreadResources();
		Voice voice = getAnyVoice(engine);
		Collection<AudioBuffer> li = engine.synthesize("<s>𝄞𝄞𝄞𝄞 水水水水水 𝄞水𝄞水𝄞水𝄞水 test 国Ø家Ť标准 ĜæŘ ß ŒÞ ๕</s>", null, voice, resource, null, BufferAllocator, false);
		engine.releaseThreadResources(resource);

		Assert.assertTrue(getSize(li) > 2000);
	}

	@Test
	public void multiSpeak() throws Throwable {
		final FilibusterEngine engine = allocateEngine();

		final Voice voice = getAnyVoice(engine);

		final int[] sizes = new int[16];
		Thread[] threads = new Thread[sizes.length];
		for (int i = 0; i < threads.length; ++i) {
			final int j = i;
			threads[i] = new Thread() {
				public void run() {
					TTSResource resource = null;
					try {
						resource = engine.allocateThreadResources();
					} catch (SynthesisException | InterruptedException e) {
						return;
					}

					Collection<AudioBuffer> li = null;
					for (int k = 0; k < 16; ++k) {
						try {
							li = engine.synthesize("small test", null, voice, resource, null, BufferAllocator, false);

						} catch (SynthesisException | InterruptedException | MemoryException e) {
							e.printStackTrace();
							break;
						}
						sizes[j] += getSize(li);
					}
					try {
						engine.releaseThreadResources(resource);
					} catch (SynthesisException | InterruptedException e) {
					}
				}
			};
		}

		for (Thread th : threads) {
			th.start();
		}

		for (Thread th : threads)
			th.join();
		
		// same size every time
		for (int size : sizes) {
			Assert.assertEquals(sizes[0], size);
		}
	}
}
