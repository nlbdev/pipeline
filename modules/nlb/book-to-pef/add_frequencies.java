import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.nio.charset.Charset;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.Map;
import java.util.TreeMap;

public class add_frequencies {
	
	public static void main(String args[]) throws Exception {
		BufferedReader statsReader = new BufferedReader(new InputStreamReader(new FileInputStream(args[0]), Charset.forName("UTF-8")));
		BufferedReader wordsReader = new BufferedReader(new InputStreamReader(System.in, Charset.forName("ISO-8859-1")));
		OutputStreamWriter out = new OutputStreamWriter(System.out, Charset.forName("ISO-8859-1"));
		Map<String,Integer> stats = parseStats(statsReader);
		String word;
		while ((word = wordsReader.readLine()) != null) {
			Integer weight = stats.get(word.replaceAll("-", ""));
			if (weight != null) {
				out.write(weight+word+"\n");
			}
		}
		statsReader.close();
		wordsReader.close();
	}
	
	private static Map<String,Integer> parseStats(BufferedReader stats) throws Exception {
		Map<String,Integer> map = new TreeMap<>();
		Pattern csv = Pattern.compile("^([^,]+),([^,]+),([^,]+)");
		String stat;
		while ((stat = stats.readLine()) != null) {
			Matcher m = csv.matcher(stat);
			if (m.matches()) {
				int weight = Integer.parseInt(m.group(3));
				if (weight == 0)
					break;
				map.put(m.group(1), weight);
			}
		}
		return map;
	}
}
