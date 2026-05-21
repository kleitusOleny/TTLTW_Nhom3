package controller.admin;

import dao.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import model.Product;

import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.DateUtil;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.WorkbookFactory;
import java.io.InputStream;

@WebServlet(name = "ProductManagerController", value = "/product-manager")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 10,      // 10MB
        maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class ProductManagerController extends HttpServlet {
    
    ProductDAO productDAO = new ProductDAO();
    ManufacturerDAO manufacturerDAO = new ManufacturerDAO();
    TagDAO tagDAO = new TagDAO();
    CategoryDAO categoryDAO = new CategoryDAO();
    TypeDAO typeDAO = new TypeDAO();
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        req.setAttribute("products", productDAO.listProduct());
        req.setAttribute("categories", categoryDAO.getAllCategories());
        req.setAttribute("types", typeDAO.getAllTypes());
        req.setAttribute("manufacturers", manufacturerDAO.getAllManufacturers());
        req.getRequestDispatcher("/admin/manage_product.jsp").forward(req, resp);
    }
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        
        try {
            if ("add".equals(action) || "edit".equals(action)) {
                // 1. Lấy dữ liệu chung
                String name = req.getParameter("name");
                double price = Double.parseDouble(req.getParameter("price"));
                int quantity = Integer.parseInt(req.getParameter("stock"));
                String origin = req.getParameter("origin");
                String capacity = req.getParameter("capacity");
                double alcohol = Double.parseDouble(req.getParameter("alcohol"));
                String detail = req.getParameter("detail");
                
                // Xử lý Upload ảnh
                Part filePart = req.getPart("image");
                String imageUrl = "";
                
                // Nếu có file mới được upload
                if (filePart != null && filePart.getSize() > 0) {
                    String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
                    String uploadPath = getServletContext().getRealPath("") + File.separator + "assets" + File.separator + "products";
                    File uploadDir = new File(uploadPath);
                    if (!uploadDir.exists()) uploadDir.mkdir();
                    
                    String finalFileName = System.currentTimeMillis() + "_" + fileName;
                    filePart.write(uploadPath + File.separator + finalFileName);
                    imageUrl = "assets/products/" + finalFileName;
                } else {
                    // Nếu không up ảnh mới -> Lấy lại ảnh cũ (đối với edit)
                    imageUrl = req.getParameter("oldImage");
                }
                
                // Map dữ liệu
                Product p = new Product();
                p.setProductName(name);
                p.setSlug(name.toLowerCase().replace(" ", "-"));
                p.setOrigin(origin);
                p.setPrice(price);
                p.setCapacity(capacity);
                p.setAlcohol(alcohol);
                p.setQuantity(quantity);
                p.setDetail(detail);
                p.setImageUrl(imageUrl);
                p.setTypeId(req.getParameter("type"));
                p.setManufacturerId(req.getParameter("manufacturer"));
                p.setCategoryId(req.getParameter("category"));
                
                if ("add".equals(action)) {
                    p.setId("P" + System.currentTimeMillis() % 100000);
                    productDAO.insert(p);
                } else {
                    // Trường hợp Edit: Lấy ID từ form
                    p.setId(req.getParameter("id"));
                    productDAO.update(p);
                }
                
            } else if ("delete".equals(action)) {
                // Xóa 1 sản phẩm
                String id = req.getParameter("id");
                productDAO.delete(id);
                
            } else if ("delete-list".equals(action)) {
                // XỬ LÝ XÓA NHIỀU (Dựa trên chuỗi ID cách nhau dấu phẩy)
                String ids = req.getParameter("ids"); // VD: "P123,P456"
                if (ids != null && !ids.isEmpty()) {
                    String[] idArray = ids.split(",");
                    for (String id : idArray) {
                        productDAO.delete(id);
                    }
                }
            } else if ("importExcel".equals(action)) {
                Part filePart = req.getPart("excelFile");
                if (filePart != null && filePart.getSize() > 0) {
                    try (InputStream fileContent = filePart.getInputStream();
                         Workbook workbook = WorkbookFactory.create(fileContent)) {
                        
                        Sheet sheet = workbook.getSheetAt(0);
                        for (int i = 1; i <= sheet.getLastRowNum(); i++) {
                            Row row = sheet.getRow(i);
                            if (row == null) continue;
                            
                            String name = getCellValueAsString(row.getCell(0));
                            if (name == null || name.trim().isEmpty()) continue;
                            
                            Product p = new Product();
                            p.setProductName(name);
                            p.setSlug(name.toLowerCase().replace(" ", "-"));
                            
                            try {
                                p.setPrice(Double.parseDouble(getCellValueAsString(row.getCell(1))));
                                p.setQuantity((int) Double.parseDouble(getCellValueAsString(row.getCell(2))));
                                p.setAlcohol(Double.parseDouble(getCellValueAsString(row.getCell(5))));
                            } catch (NumberFormatException e) {
                                p.setPrice(0.0);
                                p.setQuantity(0);
                                p.setAlcohol(0.0);
                            }
                            
                            p.setOrigin(getCellValueAsString(row.getCell(3)));
                            p.setCapacity(getCellValueAsString(row.getCell(4)));
                            p.setDetail(getCellValueAsString(row.getCell(6)));
                            p.setTypeId(getCellValueAsString(row.getCell(7)));
                            p.setManufacturerId(getCellValueAsString(row.getCell(8)));
                            p.setCategoryId(getCellValueAsString(row.getCell(9)));
                            p.setImageUrl(getCellValueAsString(row.getCell(10)));
                            
                            p.setId("P" + System.currentTimeMillis() % 100000 + i);
                            
                            productDAO.insert(p);
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        resp.sendRedirect("product-manager");
    }
    
    private String getCellValueAsString(Cell cell) {
        if (cell == null) return "";
        switch (cell.getCellType()) {
            case STRING:
                return cell.getStringCellValue();
            case NUMERIC:
                if (DateUtil.isCellDateFormatted(cell)) {
                    return cell.getDateCellValue().toString();
                } else {
                    double num = cell.getNumericCellValue();
                    if (num == Math.floor(num)) {
                        return String.valueOf((long) num);
                    }
                    return String.valueOf(num);
                }
            case BOOLEAN:
                return String.valueOf(cell.getBooleanCellValue());
            case FORMULA:
                return cell.getCellFormula();
            default:
                return "";
        }
    }
}