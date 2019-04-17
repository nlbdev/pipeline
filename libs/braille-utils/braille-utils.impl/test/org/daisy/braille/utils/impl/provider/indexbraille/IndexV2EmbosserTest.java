package org.daisy.braille.utils.impl.provider.indexbraille;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;

import javax.xml.parsers.ParserConfigurationException;

import org.daisy.dotify.api.embosser.EmbosserCatalog;
import org.daisy.dotify.api.embosser.EmbosserFeatures;
import org.daisy.dotify.api.embosser.EmbosserWriter;
import org.daisy.dotify.api.paper.PageFormat;
import org.daisy.dotify.api.paper.PaperCatalog;
import org.daisy.dotify.api.paper.SheetPaper;
import org.daisy.dotify.api.paper.SheetPaperFormat;
import org.daisy.dotify.api.paper.TractorPaper;
import org.daisy.dotify.api.paper.TractorPaperFormat;
import org.daisy.dotify.api.table.TableCatalog;
import org.daisy.braille.utils.pef.FileCompare;
import org.daisy.braille.utils.pef.PEFConverterFacade;
import org.daisy.braille.utils.pef.PEFHandler;
import org.daisy.braille.utils.pef.UnsupportedWidthException;
import org.daisy.dotify.common.io.FileIO;
import org.junit.Test;
import org.xml.sax.SAXException;

/**
 *
 * @author Bert Frees
 */
@SuppressWarnings("javadoc")
public class IndexV2EmbosserTest {

	private static final EmbosserCatalog ec = EmbosserCatalog.newInstance();
	private static final PaperCatalog pc = PaperCatalog.newInstance();
	private static final PageFormat a3 = new SheetPaperFormat((SheetPaper)pc.get("org_daisy.ISO216PaperProvider.PaperSize.A3"), SheetPaperFormat.Orientation.REVERSED);
	private static final PageFormat a4 = new SheetPaperFormat((SheetPaper)pc.get("org_daisy.ISO216PaperProvider.PaperSize.A4"), SheetPaperFormat.Orientation.DEFAULT);
	private static final PageFormat _210mm_12inch = new TractorPaperFormat((TractorPaper)pc.get("org_daisy.TractorPaperProvider.PaperSize.W210MM_X_H12INCH"));
	private static final PageFormat _280mm_12inch = new TractorPaperFormat((TractorPaper)pc.get("org_daisy.TractorPaperProvider.PaperSize.W280MM_X_H12INCH"));
	
	private static IndexV2Embosser getBasicS() {
		return (IndexV2Embosser)ec.get("com_indexbraille.IndexEmbosserProvider.EmbosserType.INDEX_BASIC_S_V2");
	}
	
	private static IndexV2Embosser getBasicD() {
		return (IndexV2Embosser)ec.get("com_indexbraille.IndexEmbosserProvider.EmbosserType.INDEX_BASIC_D_V2");
	}
	
	private static IndexV2Embosser getEverest() {
		return (IndexV2Embosser)ec.get("com_indexbraille.IndexEmbosserProvider.EmbosserType.INDEX_EVEREST_D_V2");
	}
	
	private static IndexV2Embosser get4x4Pro() {
		return (IndexV2Embosser)ec.get("com_indexbraille.IndexEmbosserProvider.EmbosserType.INDEX_4X4_PRO_V2");
	}

	@Test
	public void testPrintableArea() {
		IndexV2Embosser basic_s = getBasicS();
		IndexV2Embosser _4x4pro = get4x4Pro();

		assertEquals("Assert that max width for a 210mm by 12 inch paper is 35 cells (Basic-S)",  35, basic_s.getMaxWidth(_210mm_12inch));
		assertEquals("Assert that max height for a 210mm by 12 inch paper is 30 lines (Basic-S)", 30, basic_s.getMaxHeight(_210mm_12inch));
		assertEquals("Assert that the absolute max width is 41 cells (Basic-S)",                  41, basic_s.getMaxWidth(_280mm_12inch));

		_4x4pro.setFeature(EmbosserFeatures.SADDLE_STITCH, false);

		assertEquals("Assert that the absolute max width is 42 cells (4X4 Pro)",  42, _4x4pro.getMaxWidth(a3));
		assertEquals("Assert that the absolute max height is 24 lines (4X4 Pro)", 24, _4x4pro.getMaxHeight(a3));

		_4x4pro.setFeature(EmbosserFeatures.SADDLE_STITCH, true);

		assertEquals("Assert that max width for a A3 paper is 35 cells (4X4 Pro, if saddle stitch mode is on)",  35, _4x4pro.getMaxWidth(a3));

	}

	@Test
	public void testTableFilter() {
		IndexV2Embosser basic_s = getBasicS();

		TableCatalog tc = TableCatalog.newInstance();
		assertTrue("Assert that encoding cannot be modified", tc.list(basic_s.getTableFilter()).size() <= 1);
	}

	@Test
	public void testDuplex() {
		IndexV2Embosser basic_s = getBasicS();
		IndexV2Embosser basic_d = getBasicD();
		IndexV2Embosser everest = getEverest();
		IndexV2Embosser _4x4pro = get4x4Pro();

		assertTrue("Assert that duplex is not supported for " + basic_s.getDisplayName(), !basic_s.supportsDuplex());
		assertTrue("Assert that duplex is supported for " + basic_d.getDisplayName(), basic_d.supportsDuplex());
		assertTrue("Assert that duplex is supported for " + everest.getDisplayName(), everest.supportsDuplex());
		assertTrue("Assert that duplex is supported for " + _4x4pro.getDisplayName(), _4x4pro.supportsDuplex());
	}

	@Test
	public void test8dot() {
		IndexV2Embosser basic_s = getBasicS();
		IndexV2Embosser basic_d = getBasicD();
		IndexV2Embosser everest = getEverest();
		IndexV2Embosser _4x4pro = get4x4Pro();

		assertTrue("Assert that 8-dot is not supported", !basic_s.supports8dot());
		assertTrue("Assert that 8-dot is not supported", !basic_d.supports8dot());
		assertTrue("Assert that 8-dot is not supported", !everest.supports8dot());
		assertTrue("Assert that 8-dot is not supported", !_4x4pro.supports8dot());
	}

	@Test
	public void testAligning() {
		IndexV2Embosser basic_s = getBasicS();
		IndexV2Embosser basic_d = getBasicD();
		IndexV2Embosser everest = getEverest();
		IndexV2Embosser _4x4pro = get4x4Pro();

		assertTrue("Assert that aligning is supported", basic_s.supportsAligning());
		assertTrue("Assert that aligning is supported", basic_d.supportsAligning());
		assertTrue("Assert that aligning is supported", everest.supportsAligning());
		assertTrue("Assert that aligning is supported", _4x4pro.supportsAligning());
	}

	@Test
	public void testEmbosserWriter() throws IOException,
	ParserConfigurationException,
	SAXException,
	UnsupportedWidthException {
		IndexV2Embosser basic_s = getBasicS();
		IndexV2Embosser basic_d = getBasicD();
		IndexV2Embosser everest = getEverest();
		IndexV2Embosser _4x4pro = get4x4Pro();

		File prn1 = File.createTempFile("test_indexv2_", ".prn");
		File prn2 = File.createTempFile("test_indexv2_", ".prn");
		File pef =  File.createTempFile("test_indexv2_", ".pef");

		FileCompare fc = new FileCompare();
		PEFHandler.Builder builder;
		EmbosserWriter w;

		basic_s.setFeature(EmbosserFeatures.PAGE_FORMAT, _280mm_12inch);
		basic_d.setFeature(EmbosserFeatures.PAGE_FORMAT, _280mm_12inch);
		everest.setFeature(EmbosserFeatures.PAGE_FORMAT, a4);
		_4x4pro.setFeature(EmbosserFeatures.PAGE_FORMAT, a3);

		// Single sided on a single sided printer

		w = basic_s.newEmbosserWriter(new FileOutputStream(prn1));
		builder = new PEFHandler.Builder(w)
				.range(null)
				.align(org.daisy.braille.utils.pef.PEFHandler.Alignment.INNER)
				.offset(0)
				.topOffset(0);

		FileIO.copy(this.getClass().getResourceAsStream("resource-files/single_sided.pef"), new FileOutputStream(pef));
		FileIO.copy(this.getClass().getResourceAsStream("resource-files/basic_s_v2_single_sided.prn"), new FileOutputStream(prn2));
		new PEFConverterFacade(EmbosserCatalog.newInstance()).parsePefFile(pef, builder.build());
		try (InputStream is2 = new FileInputStream(prn2)) {
			assertTrue("Assert that the contents of the file is as expected.",
					fc.compareBinary(new FileInputStream(prn1), is2)
					);
		}

		// Single sided on a double sided printer

		basic_d.setFeature(EmbosserFeatures.Z_FOLDING, false);
		w = basic_d.newEmbosserWriter(new FileOutputStream(prn1));
		builder = new PEFHandler.Builder(w)
				.range(null)
				.align(org.daisy.braille.utils.pef.PEFHandler.Alignment.INNER)
				.offset(0)
				.topOffset(0);

		FileIO.copy(this.getClass().getResourceAsStream("resource-files/basic_d_v2_single_sided.prn"), new FileOutputStream(prn2));
		new PEFConverterFacade(EmbosserCatalog.newInstance()).parsePefFile(pef, builder.build());
		try (InputStream is2 = new FileInputStream(prn2)) {
			assertTrue("Assert that the contents of the file is as expected.",
					fc.compareBinary(new FileInputStream(prn1), is2)
					);
		}

		// Double sided

		w = basic_d.newEmbosserWriter(new FileOutputStream(prn1));
		builder = new PEFHandler.Builder(w)
				.range(null)
				.align(org.daisy.braille.utils.pef.PEFHandler.Alignment.INNER)
				.offset(0)
				.topOffset(0);

		FileIO.copy(this.getClass().getResourceAsStream("resource-files/double_sided.pef"), new FileOutputStream(pef));
		FileIO.copy(this.getClass().getResourceAsStream("resource-files/basic_d_v2_double_sided.prn"), new FileOutputStream(prn2));
		new PEFConverterFacade(EmbosserCatalog.newInstance()).parsePefFile(pef, builder.build());
		try (InputStream is2 = new FileInputStream(prn2)) {
			assertTrue("Assert that the contents of the file is as expected.",
					fc.compareBinary(new FileInputStream(prn1), is2)
					);
		}

		// Z-folding

		basic_d.setFeature(EmbosserFeatures.Z_FOLDING, true);
		w = basic_d.newEmbosserWriter(new FileOutputStream(prn1));
		builder = new PEFHandler.Builder(w)
				.range(null)
				.align(org.daisy.braille.utils.pef.PEFHandler.Alignment.INNER)
				.offset(0)
				.topOffset(0);

		FileIO.copy(this.getClass().getResourceAsStream("resource-files/basic_d_v2_zfolding.prn"), new FileOutputStream(prn2));
		new PEFConverterFacade(EmbosserCatalog.newInstance()).parsePefFile(pef, builder.build());
		try (InputStream is2 = new FileInputStream(prn2)) {
			assertTrue("Assert that the contents of the file is as expected.",
					fc.compareBinary(new FileInputStream(prn1), is2)
					);
		}

		// Everest

		w = everest.newEmbosserWriter(new FileOutputStream(prn1));
		builder = new PEFHandler.Builder(w)
				.range(null)
				.align(org.daisy.braille.utils.pef.PEFHandler.Alignment.INNER)
				.offset(0)
				.topOffset(0);

		FileIO.copy(this.getClass().getResourceAsStream("resource-files/everest_v2_double_sided.prn"), new FileOutputStream(prn2));
		new PEFConverterFacade(EmbosserCatalog.newInstance()).parsePefFile(pef, builder.build());
		try (InputStream is2 = new FileInputStream(prn2)) {
			assertTrue("Assert that the contents of the file is as expected.",
					fc.compareBinary(new FileInputStream(prn1), is2)
					);
		}

		// 4X4 Pro

		_4x4pro.setFeature(EmbosserFeatures.SADDLE_STITCH, false);
		w = _4x4pro.newEmbosserWriter(new FileOutputStream(prn1));
		builder = new PEFHandler.Builder(w)
				.range(null)
				.align(org.daisy.braille.utils.pef.PEFHandler.Alignment.INNER)
				.offset(0)
				.topOffset(0);

		FileIO.copy(this.getClass().getResourceAsStream("resource-files/4x4_pro_v2_double_sided.prn"), new FileOutputStream(prn2));
		new PEFConverterFacade(EmbosserCatalog.newInstance()).parsePefFile(pef, builder.build());
		try (InputStream is2 = new FileInputStream(prn2)) {
			assertTrue("Assert that the contents of the file is as expected.",
					fc.compareBinary(new FileInputStream(prn1), is2)
					);
		}

		// 4X4 Pro in saddle stitch mode

		_4x4pro.setFeature(EmbosserFeatures.SADDLE_STITCH, true);
		w = _4x4pro.newEmbosserWriter(new FileOutputStream(prn1));
		builder = new PEFHandler.Builder(w)
				.range(null)
				.align(org.daisy.braille.utils.pef.PEFHandler.Alignment.INNER)
				.offset(0)
				.topOffset(0);

		FileIO.copy(this.getClass().getResourceAsStream("resource-files/4x4_pro_v2_saddle_stitch.prn"), new FileOutputStream(prn2));
		new PEFConverterFacade(EmbosserCatalog.newInstance()).parsePefFile(pef, builder.build());
		try (InputStream is2 = new FileInputStream(prn2)) {
			assertTrue("Assert that the contents of the file is as expected.",
					fc.compareBinary(new FileInputStream(prn1), is2)
					);
		}

		prn1.deleteOnExit();
		prn2.deleteOnExit();
		pef.deleteOnExit();
	}

	@Test
	public void testAgainstRelease110() throws IOException, ParserConfigurationException, SAXException, UnsupportedWidthException {
		IndexV2Embosser basic_d = getBasicD();
		IndexV2Embosser everest = getEverest();

		File prn1 = File.createTempFile("test_indexv2_", ".prn");
		FileCompare fc = new FileCompare();
		PEFHandler.Builder builder;
		EmbosserWriter w;

		// Everest V2 (against release 1.1.0, with minor improvements to the file header)
		everest.setFeature(EmbosserFeatures.PAGE_FORMAT, a4);
		w = everest.newEmbosserWriter(new FileOutputStream(prn1));
		builder = new PEFHandler.Builder(w)
				.range(null)
				.align(org.daisy.braille.utils.pef.PEFHandler.Alignment.CENTER_INNER)
				.offset(0)
				.topOffset(0);

		new PEFConverterFacade(EmbosserCatalog.newInstance()).parsePefFile(this.getClass().getResourceAsStream("resource-files/test-input-1.pef"), builder.build());
		//FileIO.copy(new FileInputStream(prn1), new FileOutputStream(new File("c:\\bu1_2.txt")));
		assertTrue("Assert that the contents of the file is as expected.",
				fc.compareBinary(new FileInputStream(prn1), this.getClass().getResourceAsStream("resource-files/test-input-1_everest-v2_a4.prn"))
				);

		// Basic V2 (against release 1.1.0, with minor improvements to the file header)
		basic_d.setFeature(EmbosserFeatures.Z_FOLDING, false);
		basic_d.setFeature(EmbosserFeatures.PAGE_FORMAT, _210mm_12inch);
		w = basic_d.newEmbosserWriter(new FileOutputStream(prn1));

		builder = new PEFHandler.Builder(w)
				.range(null)
				.align(org.daisy.braille.utils.pef.PEFHandler.Alignment.CENTER_INNER)
				.offset(0)
				.topOffset(0);

		new PEFConverterFacade(EmbosserCatalog.newInstance()).parsePefFile(this.getClass().getResourceAsStream("resource-files/test-input-1.pef"), builder.build());
		//FileIO.copy(new FileInputStream(prn1), new FileOutputStream(new File("c:\\bu1_2.txt")));
		assertTrue("Assert that the contents of the file is as expected.",
				fc.compareBinary(new FileInputStream(prn1), this.getClass().getResourceAsStream("resource-files/test-input-1_basic-v2_12inch.prn"))
				);

		prn1.deleteOnExit();
	}
}
