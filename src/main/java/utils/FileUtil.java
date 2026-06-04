package utils;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;

public class FileUtil {

    public static String uploadImage(Part part, HttpServletRequest request, String targetFolder) {
        if (part == null || part.getSize() <= 0) return null;
        
        String submittedName = part.getSubmittedFileName();
        if (submittedName == null || submittedName.isEmpty()) return null;

        try {
            String fileName = Paths.get(submittedName).getFileName().toString();
            String finalFileName = System.currentTimeMillis() + "_" + fileName;

            String uploadPath = request.getServletContext().getRealPath("") + File.separator + "assets" + File.separator + targetFolder;
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) uploadDir.mkdirs();
            File file = new File(uploadDir, finalFileName);
            String sourcePath = "../src/main/webapp/assets/" + targetFolder;
            File sourceDir = new File(sourcePath);
            if (!sourceDir.exists()) sourceDir.mkdirs();
            File sourceFile = new File(sourceDir, finalFileName);
            try (InputStream fileContent = part.getInputStream()) {
                Files.copy(fileContent, file.toPath(), StandardCopyOption.REPLACE_EXISTING);
            }
            
            try {
                Files.copy(file.toPath(), sourceFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
            } catch (Exception e) {
                System.out.println("Không thể sao chép file vào Source Code: " + e.getMessage());
            }

            return "assets/" + targetFolder + "/" + finalFileName;
            
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public static void deleteFile(String imagePath, HttpServletRequest request) {
        if (imagePath == null || imagePath.isEmpty()) return;

        try {
            String serverPath = request.getServletContext().getRealPath("") + File.separator + imagePath;
            File serverFile = new File(serverPath);
            if (serverFile.exists()) {
                serverFile.delete();
            }
            String sourcePath = "../src/main/webapp/" + imagePath;
            File sourceFile = new File(sourcePath);
            if (sourceFile.exists()) {
                sourceFile.delete();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
