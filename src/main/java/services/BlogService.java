package services;

import java.net.URL;
import java.net.URLConnection;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

import com.rometools.rome.feed.synd.SyndEntry;
import com.rometools.rome.feed.synd.SyndFeed;
import com.rometools.rome.io.SyndFeedInput;
import com.rometools.rome.io.XmlReader;
import dao.BlogDAO;
import model.Blogs;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;

import java.net.URL;
import java.net.URLConnection;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

public class BlogService {
    BlogDAO blog=new BlogDAO();
    static List<String> alcoholKeywords = List.of("rượu", "rượu vang", "wine", "whisky", "whiskey", "cocktail", "beer", "bartender", "sommelier", "mixology", "sake", "vodka", "gin", "rum", "chivas", "macallan", "johnnie walker", "heineken", "tiger beer", "craft beer");

    static List<String> lifestyleKeywords = List.of("fine dining", "ẩm thực", "nhà hàng", "luxury", "resort", "chef", "pairing", "steak", "hải sản", "buffet", "thưởng thức", "ẩm thực cao cấp");

    static List<String> negativeKeywords = List.of("tai nạn", "tử vong", "ngộ độc", "đánh nhau", "say xỉn", "vi phạm", "buôn lậu", "phạm tội", "bị phạt", "ma túy", "đâm chém");

    public void createBlog(){

        List<String> rssFeeds = new ArrayList<>();
        rssFeeds.add("https://vnexpress.net/rss/am-thuc.rss");
        rssFeeds.add("https://vnexpress.net/rss/doi-song.rss");
        rssFeeds.add("https://vnexpress.net/rss/du-lich.rss");

        rssFeeds.add("https://thanhnien.vn/rss/du-lich.rss");
        rssFeeds.add("https://thanhnien.vn/rss/doi-song.rss");
        rssFeeds.add("https://thanhnien.vn/rss/van-hoa.rss");

        rssFeeds.add("https://dantri.com.vn/rss/du-lich.rss");
        rssFeeds.add("https://dantri.com.vn/rss/kinh-doanh.rss");
        rssFeeds.add("https://dantri.com.vn/rss/nhip-song-tre.rss");

        rssFeeds.add("https://tuoitre.vn/rss/nhip-song-tre.rss");
        rssFeeds.add("https://tuoitre.vn/rss/van-hoa.rss");
        rssFeeds.add("https://tuoitre.vn/rss/du-lich.rss");

        rssFeeds.add("https://vietnamnet.vn/rss/du-lich.rss");
        rssFeeds.add("https://vietnamnet.vn/rss/doi-song.rss");
        rssFeeds.add("https://vietnamnet.vn/rss/am-thuc.rss");

        rssFeeds.add("https://laodong.vn/rss/du-lich.rss");
        rssFeeds.add("https://laodong.vn/rss/van-hoa-giai-tri.rss");

        rssFeeds.add("https://znews.vn/rss/am-thuc.rss");
        rssFeeds.add("https://znews.vn/rss/du-lich.rss");
        rssFeeds.add("https://znews.vn/rss/lifestyle.rss");

        rssFeeds.add("https://cafebiz.vn/rss/home.rss");

        rssFeeds.add("https://nld.com.vn/rss/du-lich.rss");
        rssFeeds.add("https://nld.com.vn/rss/am-thuc.rss");

        rssFeeds.add("https://forbes.vn/feed/");

        rssFeeds.add("https://vietcetera.com/vn/rss");

        rssFeeds.add("https://travellive.com/rss");

        for (String rssUrl : rssFeeds) {
            try {

                URL url = new URL(rssUrl);

                URLConnection connection = url.openConnection();

                connection.setRequestProperty("User-Agent", "Mozilla/5.0");

                connection.setConnectTimeout(10000);

                connection.setReadTimeout(10000);

                SyndFeed feed;

                try (XmlReader reader = new XmlReader(connection.getInputStream())) {

                    SyndFeedInput input = new SyndFeedInput();

                    feed = input.build(reader);
                }

                for (SyndEntry entry : feed.getEntries()) {

                    String title = safeString(entry.getTitle());


                    String link = safeString(entry.getLink());

                    String description = "";

                    if (entry.getDescription() != null) {

                        description = safeString(entry.getDescription().getValue());
                    }
                    String cleanDescription = Jsoup.parse(description).text();

                    String content = (title + " " + cleanDescription).toLowerCase();
                    int alcoholScore = 0;
                    int lifestyleScore = 0;
                    int negativeScore = 0;

                    for (String keyword : alcoholKeywords) {

                        if (containsKeyword(content, keyword)) {

                            alcoholScore += 3;
                        }
                    }

                    for (String keyword : lifestyleKeywords) {

                        if (containsKeyword(content, keyword)) {

                            lifestyleScore += 1;
                        }
                    }

                    for (String keyword : negativeKeywords) {

                        if (containsKeyword(content, keyword)) {

                            negativeScore += 5;
                        }
                    }

                    boolean isAlcoholRelated = alcoholScore >= 6;

                    boolean isNegative = negativeScore >= 5;

                    if (!isAlcoholRelated || isNegative) {

                        continue;
                    }

                    String image = "";

                    try {

                        Document doc = Jsoup.parse(description);

                        image = doc.select("img").attr("src");

                    } catch (Exception ignored) {
                    }

                    String category = detectCategory(content);
                    Blogs blogs=new Blogs();
                    blogs.setLink(link);
                    blogs.setBlogImage(image);
                    blogs.setTitle(title);
                    blogs.setCategory(category);
                    blogs.setDisplay(false);
                    blogs.setCreateAt(LocalDate.now());
                    blogs.setUpdateAt(LocalDate.now());
                    blogs.setUploadAt(null);
                    blogs.setDelete(0);
                    if (!blog.existsByTitle(title)) {
                        blog.insert(blogs);
                    }


                    System.out.println("TITLE: " + title);

                    System.out.println("CATEGORY: " + category);

                    System.out.println("LINK: " + link);

                    System.out.println("IMAGE: " + image);

                    System.out.println("ALCOHOL SCORE: " + alcoholScore);

                    System.out.println("LIFESTYLE SCORE: " + lifestyleScore);

                    System.out.println("PUBLISHED: " + entry.getPublishedDate());

                    System.out.println("---------------------------------");

                }

            } catch (Exception e) {

                System.out.println("ERROR RSS: " + rssUrl);

                e.printStackTrace();
            }
        }
    }

    public static String safeString(String value) {

        return value == null ? "" : value.trim();
    }

    public static boolean containsKeyword(String content, String keyword) {

        String regex = "\\b" + Pattern.quote(keyword.toLowerCase()) + "\\b";

        return Pattern.compile(regex).matcher(content.toLowerCase()).find();
    }

    public static String detectCategory(String content) {

        if (containsKeyword(content, "wine") || containsKeyword(content, "rượu vang")) {

            return "Wine";
        }

        if (containsKeyword(content, "whisky") || containsKeyword(content, "whiskey") || containsKeyword(content, "macallan") || containsKeyword(content, "chivas")) {

            return "Whisky";
        }

        if (containsKeyword(content, "cocktail") || containsKeyword(content, "bartender") || containsKeyword(content, "mixology")) {

            return "Cocktail";
        }

        if (containsKeyword(content, "beer") || containsKeyword(content, "heineken") || containsKeyword(content, "tiger beer")) {

            return "Beer";
        }

        return "Lifestyle";
    }
    public List<Blogs> getBlogsDisAccept(){
        return blog.getAllDisAccept();
    }
    public List<Blogs> getBlogsAccept(){
        return blog.getAll();
    }

    public List<Blogs> searchBlogs(String text, String category, int limit, int offset) {
        return blog.searchBlogs(text, category, limit, offset);
    }

    public int countBlogs(String text, String category) {
        return blog.countBlogs(text, category);
    }
}
