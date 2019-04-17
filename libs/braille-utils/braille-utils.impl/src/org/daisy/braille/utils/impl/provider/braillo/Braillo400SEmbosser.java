/*
 * Braille Utils (C) 2010-2011 Daisy Consortium 
 * 
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 * 
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 * 
 * You should have received a copy of the GNU Lesser General Public License
 * along with this library; if not, write to the Free Software Foundation, Inc.,
 * 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 */
package org.daisy.braille.utils.impl.provider.braillo;

import org.daisy.dotify.api.embosser.EmbosserFactoryProperties;
import org.daisy.dotify.api.paper.PageFormat;
import org.daisy.dotify.api.paper.Paper;
import org.daisy.dotify.api.table.TableCatalogService;

public class Braillo400SEmbosser extends AbstractBraillo200Embosser {

	/**
	 * 
	 */
	private static final long serialVersionUID = 458179752397011984L;

	public Braillo400SEmbosser(TableCatalogService service, EmbosserFactoryProperties props) {
		super(service, props);
	}

	@Override
	public boolean supportsPageFormat(PageFormat pageFormat) {
		return pageFormat.getPageFormatType() == PageFormat.Type.TRACTOR
				&& pageFormat.asTractorPaperFormat().getLengthAcrossFeed().asMillimeter() >= 140
				&& pageFormat.asTractorPaperFormat().getLengthAcrossFeed().asMillimeter() <= 330
				&& pageFormat.asTractorPaperFormat().getLengthAlongFeed().asInches() >= 4
				&& pageFormat.asTractorPaperFormat().getLengthAlongFeed().asInches() <= 14;
	}

	@Override
	public boolean supportsPaper(Paper paper) {
		return paper.getType() == Paper.Type.TRACTOR
				&& paper.asTractorPaper().getLengthAcrossFeed().asMillimeter() >= 140
				&& paper.asTractorPaper().getLengthAcrossFeed().asMillimeter() <= 330
				&& paper.asTractorPaper().getLengthAlongFeed().asInches() >= 4
				&& paper.asTractorPaper().getLengthAlongFeed().asInches() <= 14;
	}
}
