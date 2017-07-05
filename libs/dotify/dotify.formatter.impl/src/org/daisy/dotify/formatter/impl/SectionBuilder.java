package org.daisy.dotify.formatter.impl;

import java.util.List;
import java.util.Stack;

import org.daisy.dotify.writer.impl.Section;

class SectionBuilder {
    private Stack<Section> ret = new Stack<Section>();
    private PageSequenceBuilder2 currentSeq = null;
    private int sheets = 0;

    void addSheet(Sheet s) {
        sheets++;
        if (ret.isEmpty() || currentSeq!=s.getPageSequence()) {
            currentSeq = s.getPageSequence();
            ret.add(new SectionImpl(currentSeq.getSectionProperties()));
        }
        SectionImpl sect = ((SectionImpl)ret.peek()); 
        for (PageImpl p : s.getPages()) {
        	sect.addPage(p);
        }
    }
    
    List<Section> getSections() {
        return ret;
    }
    
    int getSheetCount() {
        return sheets;
    }

}