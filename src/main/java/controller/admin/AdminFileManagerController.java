package controller.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import utils.FileUtil;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import jakarta.servlet.annotation.MultipartConfig;
import java.util.Map;

@WebServlet(name = "AdminFileManagerController", urlPatterns = {"/admin/manage-files"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2,
        maxFileSize = 1024 * 1024 * 10,
        maxRequestSize = 1024 * 1024 * 50
)
public class AdminFileManagerController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        model.User user = (model.User) request.getSession().getAttribute("user");
        if (user == null || user.getAdministrator() != 1) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String targetFolder = request.getParameter("folder");
        if (targetFolder == null || targetFolder.isEmpty()) {
            targetFolder = "reviews"; // default
        }
        
        String serverPath = getServletContext().getRealPath("") + File.separator + "assets" + File.separator + targetFolder;
        File dir = new File(serverPath);
        
        String sourcePath = "../src/main/webapp/assets/" + targetFolder;
        
        List<Map<String, Object>> filesList = new ArrayList<>();
        if (dir.exists() && dir.isDirectory()) {
            File[] files = dir.listFiles();
            if (files != null) {
                for (File f : files) {
                    if (f.isFile()) {
                        Map<String, Object> fileInfo = new HashMap<>();
                        fileInfo.put("name", f.getName());
                        fileInfo.put("size", f.length() / 1024 + " KB"); // File size in KB
                        fileInfo.put("path", "assets/" + targetFolder + "/" + f.getName());
                        filesList.add(fileInfo);
                    }
                }
            }
        }

        request.setAttribute("activePage", "files");
        request.setAttribute("currentFolder", targetFolder);
        request.setAttribute("serverPath", serverPath);
        request.setAttribute("sourcePath", sourcePath);
        request.setAttribute("filesList", filesList);
        request.getRequestDispatcher("/admin/manage_files.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("delete".equals(action)) {
            String imagePath = request.getParameter("imagePath");
            if (imagePath != null && !imagePath.isEmpty()) {
                FileUtil.deleteFile(imagePath, request);
                request.getSession().setAttribute("successMsg", "Đã xóa file thành công!");
            }
        } else if ("upload".equals(action)) {
            jakarta.servlet.http.Part filePart = request.getPart("image");
            String folder = request.getParameter("folder");
            if (folder == null || folder.isEmpty()) folder = "reviews";
            
            String imagePath = FileUtil.uploadImage(filePart, request, folder);
            if (imagePath != null) {
                request.getSession().setAttribute("successMsg", "Đã tải ảnh lên thành công!");
            } else {
                request.getSession().setAttribute("successMsg", "Tải ảnh lên thất bại (file rỗng hoặc lỗi)!");
            }
        }
        String currentFolder = request.getParameter("folder");
        if (currentFolder == null) currentFolder = "reviews";
        response.sendRedirect(request.getContextPath() + "/admin/manage-files?folder=" + currentFolder);
    }
}
