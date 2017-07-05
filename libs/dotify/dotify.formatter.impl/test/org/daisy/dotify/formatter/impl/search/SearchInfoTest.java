package org.daisy.dotify.formatter.impl.search;

import static org.junit.Assert.assertEquals;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Map;

import org.daisy.dotify.api.formatter.Marker;
import org.daisy.dotify.formatter.impl.search.DocumentSpace;
import org.daisy.dotify.formatter.impl.search.PageDetails;
import org.daisy.dotify.formatter.impl.search.SearchInfo;
import org.daisy.dotify.formatter.impl.search.SequenceId;
import org.daisy.dotify.formatter.impl.search.Space;
import org.daisy.dotify.formatter.impl.search.View;
import org.junit.Test;

@SuppressWarnings("javadoc")
public class SearchInfoTest {
	
	@Test
	public void testSearchInfo_01() {
		SearchInfo si = new SearchInfo();
		addPages(si, 6, 0, true, 0, 0, new DocumentSpace(Space.PRE_CONTENT, 0));
		addPages(si, 3, 0, true, 0, 0, DocumentSpace.BODY);
		addPages(si, 3, 3, true, 0, 0, DocumentSpace.BODY);
		addPages(si, 6, 0, true, 0, 0, new DocumentSpace(Space.POST_CONTENT, 0));
		
		si.setVolumeScope(1, 0, 3, DocumentSpace.BODY);
		si.setVolumeScope(2, 3, 6, DocumentSpace.BODY);
		si.setSequenceScope(DocumentSpace.BODY, 0, 0, 6);
		View<PageDetails> vol1 = si.getContentsInVolume(1, DocumentSpace.BODY);
		assertEquals(3, vol1.size());
		
		View<PageDetails> vol2 = si.getContentsInVolume(2, DocumentSpace.BODY);
		assertEquals(3, vol2.size());
		
		View<PageDetails> seq = si.getContentsInSequence(new SequenceId(0, DocumentSpace.BODY));
		assertEquals(6, seq.size());
	}
	
	private static void addPages(SearchInfo si, int count, int offset, boolean duplex, int globalStartIndex, int sequenceId, DocumentSpace space) {
		addPages(si, count, offset, duplex, globalStartIndex, sequenceId, space, Collections.emptyMap());
	}
	
	private static void addPages(SearchInfo si, int count, int offset, boolean duplex, int globalStartIndex, int sequenceId, DocumentSpace space, Map<Integer, ArrayList<Marker>> marker) {
		for (int i=0; i<count; i++) {
			PageDetails pd = new PageDetails(true, i+offset, globalStartIndex, new SequenceId(sequenceId, space));
			ArrayList<Marker> m = marker.get(i+offset);
			if (m!=null) {
				pd.getMarkers().addAll(m);
			}
			si.addPageDetails(pd);
		}
	}

}
