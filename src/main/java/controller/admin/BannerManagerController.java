package controller.admin;
 
import dao.BannerDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import model.Banner;
 
import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.sql.Timestamp;
import java.util.List;
 
@WebServlet(name = "BannerManagerController", urlPatterns = {
        "/banner-manager",
        "/banner-manager/add",
        "/banner-manager/edit",
        "/banner-manager/delete",
        "/banner-manager/delete-list"
})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 10,      // 10MB
        maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class BannerManagerController extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        BannerDAO dao = new BannerDAO();
        List<Banner> banners = dao.getAllBanners();
        request.setAttribute("banners", banners);
        
        request.getRequestDispatcher("admin/manage_banner.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            String path = request.getServletPath();
            if (path.endsWith("/add")) action = "add";
            else if (path.endsWith("/edit")) action = "edit";
            else if (path.endsWith("/delete")) action = "delete";
            else if (path.endsWith("/delete-list")) action = "delete-list";
        }
        BannerDAO dao = new BannerDAO();
        
        try {
            if ("add".equals(action) || "edit".equals(action)) {
                // Xử lý Upload ảnh banner
                Part filePart = request.getPart("image");
                String imageUrl = "";
                
                if (filePart != null && filePart.getSize() > 0) {
                    String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
                    String uploadPath = getServletContext().getRealPath("");
                    if (uploadPath == null) {
                        uploadPath = getServletContext().getRealPath("/");
                    }
                    if (uploadPath == null) {
                        uploadPath = System.getProperty("user.dir");
                    }
                    uploadPath = uploadPath + File.separator + "assets" + File.separator + "banners";
                    File uploadDir = new File(uploadPath);
                    if (!uploadDir.exists()) uploadDir.mkdirs();
                    
                    String finalFileName = System.currentTimeMillis() + "_" + fileName;
                    filePart.write(uploadPath + File.separator + finalFileName);
                    imageUrl = "assets/banners/" + finalFileName;
                } else {
                    imageUrl = request.getParameter("oldImage");
                }
                
                if ("add".equals(action)) {
                    Banner b = new Banner();
                    b.setName(request.getParameter("name"));
                    b.setUrlBanner(imageUrl);
                    b.setTargetUrl(request.getParameter("targetUrl"));
                    
                    String dateStr = request.getParameter("eventDate");
                    if(dateStr != null && !dateStr.isEmpty()) {
                        if(dateStr.length() <= 10) dateStr += " 00:00:00";
                        b.setEventDate(Timestamp.valueOf(dateStr));
                    }
                    
                    b.setLifeTime(Integer.parseInt(request.getParameter("lifeTime")));
                    b.setActive("Active".equals(request.getParameter("status")));
                    
                    dao.insertBanner(b);
                } else {
                    String idStr = request.getParameter("id");
                    if(idStr != null && !idStr.isEmpty()){
                        Banner b = new Banner();
                        b.setId(Integer.parseInt(idStr));
                        b.setName(request.getParameter("name"));
                        b.setUrlBanner(imageUrl);
                        b.setTargetUrl(request.getParameter("targetUrl"));
                        
                        String dateStr = request.getParameter("eventDate");
                        if(dateStr != null && !dateStr.isEmpty()) {
                            if(dateStr.length() <= 10) dateStr += " 00:00:00";
                            b.setEventDate(Timestamp.valueOf(dateStr));
                        }
                        
                        b.setLifeTime(Integer.parseInt(request.getParameter("lifeTime")));
                        b.setActive("Active".equals(request.getParameter("status")));
                        
                        dao.updateBanner(b);
                    }
                }
            } else if ("delete".equals(action)) {
                String idStr = request.getParameter("id");
                if (idStr != null && !idStr.isEmpty()) {
                    int id = Integer.parseInt(idStr);
                    dao.deleteBanner(id);
                }
            } else if ("delete-list".equals(action)) {
                String ids = request.getParameter("ids");
                if (ids != null && !ids.isEmpty()) {
                    String[] idArray = ids.split(",");
                    for (String idStr : idArray) {
                        try {
                            int id = Integer.parseInt(idStr.trim());
                            dao.deleteBanner(id);
                        } catch (Exception e) {}
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        response.sendRedirect(request.getContextPath() + "/banner-manager");
    }
}