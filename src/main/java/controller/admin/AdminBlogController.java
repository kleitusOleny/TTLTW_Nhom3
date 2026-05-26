package controller.admin;

import dao.BlogDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Blogs;
import services.BlogService;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "AdminBlogController", urlPatterns = {"/admin/manage-blog", "/admin/get-blog", "/admin/delete-blog", "/admin/bulk-delete-blog", "/admin/update-blog", "/fetch-news", "/admin/approve-news"})
public class AdminBlogController extends HttpServlet {

    private BlogService blogService;

    @Override
    public void init() throws ServletException {
        blogService = new BlogService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();

        if ("/admin/manage-blog".equals(path)) {
            List<Blogs> allBlogs = new ArrayList<>(blogService.getBlogsAccept());
            
            req.setAttribute("blogs", allBlogs);
            req.getRequestDispatcher("/admin/manage_blog.jsp").forward(req, resp);

        } else if ("/fetch-news".equals(path)) {
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            
            try {
                blogService.createBlog();
                List<Blogs> unapprovedBlogs = blogService.getBlogsDisAccept();
                
                StringBuilder json = new StringBuilder();
                json.append("{\"success\":true,\"message\":\"Lấy tin tức thành công!\",\"news\":[");
                for (int i = 0; i < unapprovedBlogs.size(); i++) {
                    Blogs b = unapprovedBlogs.get(i);
                    json.append("{\"id\":").append(b.getId())
                        .append(",\"title\":\"").append(escapeJson(b.getTitle()))
                        .append("\",\"link\":\"").append(escapeJson(b.getLink()))
                        .append("\",\"image\":\"").append(escapeJson(b.getBlogImage()))
                        .append("\",\"source_name\":\"").append(escapeJson(b.getCategory()))
                        .append("\"}");
                    if (i < unapprovedBlogs.size() - 1) {
                        json.append(",");
                    }
                }
                json.append("]}");
                
                resp.getWriter().write(json.toString());
            } catch (Exception e) {
                e.printStackTrace();
                resp.getWriter().write("{\"success\":false,\"message\":\"Lỗi khi lấy tin tức!\"}");
            }
        } else if ("/admin/get-blog".equals(path)) {
            String idStr = req.getParameter("id");
            if (idStr != null) {
                try {
                    int id = Integer.parseInt(idStr);
                    BlogDAO blogDAO = new BlogDAO();
                    Blogs b = blogDAO.getById(id);
                    if (b != null) {
                        resp.setContentType("application/json");
                        resp.setCharacterEncoding("UTF-8");
                        
                        String json = "{\"id\":" + b.getId() + ","
                                + "\"title\":\"" + escapeJson(b.getTitle()) + "\","
                                + "\"link\":\"" + escapeJson(b.getLink()) + "\","
                                + "\"blogImage\":\"" + escapeJson(b.getBlogImage()) + "\","
                                + "\"category\":\"" + escapeJson(b.getCategory()) + "\","
                                + "\"display\":" + b.isDisplay() + "}";
                        
                        resp.getWriter().write(json);
                        return;
                    }
                } catch (NumberFormatException e) {
                    e.printStackTrace();
                }
            }
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        BlogDAO blogDAO = new BlogDAO();

        if ("/admin/delete-blog".equals(path)) {
            String idParam = req.getParameter("id");
            if (idParam != null) {
                blogDAO.delete(Integer.parseInt(idParam));
            }
            resp.sendRedirect(req.getContextPath() + "/admin/manage-blog");
            
        } else if ("/admin/bulk-delete-blog".equals(path)) {
            String[] blogIds = req.getParameterValues("blogIds");
            if (blogIds != null) {
                for (String idStr : blogIds) {
                    try {
                        blogDAO.delete(Integer.parseInt(idStr));
                    } catch (NumberFormatException e) {
                        e.printStackTrace();
                    }
                }
            }
            resp.sendRedirect(req.getContextPath() + "/admin/manage-blog");
            
        } else if ("/admin/update-blog".equals(path)) {
            int id = Integer.parseInt(req.getParameter("id"));
            String status = req.getParameter("status");
            boolean display = "Hiện".equals(status);
            
            Blogs b = blogDAO.getById(id);
            if (b != null) {
                b.setDisplay(display);
                b.setDelete(display ? 0 : 1);
                blogDAO.update(b);
            }
            resp.sendRedirect(req.getContextPath() + "/admin/manage-blog");
            
        } else if ("/admin/approve-news".equals(path)) {
            String[] newsIds = req.getParameterValues("newsIds");
            if (newsIds != null) {
                for (String idStr : newsIds) {
                    try {
                        int id = Integer.parseInt(idStr);
                        Blogs b = blogDAO.getById(id);
                        if (b != null) {
                            b.setDisplay(true);
                            blogDAO.update(b);
                        }
                    } catch (NumberFormatException e) {
                        e.printStackTrace();
                    }
                }
            }
            resp.sendRedirect(req.getContextPath() + "/admin/manage-blog");
        }
    }

    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "");
    }
}
