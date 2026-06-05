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
import model.ProductReceipt;
import model.ProductReceiptDetail;
import java.math.BigDecimal;
import db.JdbiConnector;

import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;

import model.User;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.WorkbookFactory;
import utils.ExcelUtil;

import java.io.InputStream;
import com.google.gson.Gson;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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
                double price = 0.0;
                try {
                    price = Double.parseDouble(req.getParameter("price"));
                } catch (Exception e) {}
                
                int quantity = 10;
                try {
                    quantity = Integer.parseInt(req.getParameter("stock"));
                } catch (Exception e) {}
                
                String origin = req.getParameter("origin");
                String capacity = req.getParameter("capacity");
                
                double alcohol = 0.0;
                String alcoholParam = req.getParameter("alcohol");
                if (alcoholParam != null && !alcoholParam.trim().isEmpty()) {
                    try {
                        alcohol = Double.parseDouble(alcoholParam.trim());
                    } catch (Exception e) {}
                }
                String detail = req.getParameter("detail");
                
                // Xử lý Upload ảnh
                Part filePart = req.getPart("image");
                String imageUrl = "";
                
                // Nếu có file mới được upload
                if (filePart != null && filePart.getSize() > 0) {
                    String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
                    String uploadPath = getServletContext().getRealPath("");
                    if (uploadPath == null) {
                        uploadPath = getServletContext().getRealPath("/");
                    }
                    if (uploadPath == null) {
                        uploadPath = System.getProperty("user.dir");
                    }
                    uploadPath = uploadPath + File.separator + "assets" + File.separator + "products";
                    File uploadDir = new File(uploadPath);
                    if (!uploadDir.exists()) uploadDir.mkdirs();
                    
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
                p.setSlug(name != null ? name.toLowerCase().replace(" ", "-") : "");
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
                    int initialQty = p.getQuantity();
                    p.setQuantity(0); // Đặt về 0 để transaction nhập kho cập nhật chính xác số lượng
                    productDAO.insert(p);
                    
                    if (initialQty > 0) {
                        ProductReceipt receipt = new ProductReceipt();
                        User user = (User) req.getSession().getAttribute("user");
                        receipt.setUserId(user != null ? user.getId() : 1);
                        if (p.getManufacturerId() != null && !p.getManufacturerId().trim().isEmpty()) {
                            try {
                                receipt.setSupplierId(Integer.parseInt(p.getManufacturerId()));
                            } catch (Exception e) {}
                        }
                        receipt.setNote("Tự động tạo khi thêm sản phẩm mới: " + p.getProductName());
                        receipt.setTotalAmount(BigDecimal.valueOf(p.getPrice() * initialQty));
                        
                        List<ProductReceiptDetail> details = new ArrayList<>();
                        ProductReceiptDetail productReceiptDetail = new ProductReceiptDetail();
                        productReceiptDetail.setProductId(p.getId());
                        productReceiptDetail.setQuantity(initialQty);
                        productReceiptDetail.setUnitPrice(BigDecimal.valueOf(p.getPrice()));
                        details.add(productReceiptDetail);
                        receipt.setDetails(details);
                        
                        ProductReceiptDAO receiptDAO = JdbiConnector.get().onDemand(ProductReceiptDAO.class);
                        receiptDAO.processReceipt(receipt);
                    }
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
                resp.setContentType("application/json");
                resp.setCharacterEncoding("UTF-8");
                Map<String, Object> result = new HashMap<>();
                
                Part filePart = req.getPart("excelFile");
                if (filePart != null && filePart.getSize() > 0) {
                    try (InputStream fileContent = filePart.getInputStream();
                         Workbook workbook = WorkbookFactory.create(fileContent)) {
                        
                        Sheet sheet = workbook.getSheetAt(0);
                        List<Product> productList = new ArrayList<>();
                        
                        for (int i = 1; i <= sheet.getLastRowNum(); i++) {
                            Row row = sheet.getRow(i);
                            if (row == null) continue;
                            
                            String name = ExcelUtil.getCellValueAsString(row.getCell(0));
                            if (name == null || name.trim().isEmpty()) continue;
                            
                            Product p = new Product();
                            p.setProductName(name);
                            p.setSlug(name.toLowerCase().replace(" ", "-"));
                            
                            double price = 0.0;
                            int quantity = 0;
                            double alcohol = 0.0;
                            try {
                                price = Double.parseDouble(ExcelUtil.getCellValueAsString(row.getCell(1)));
                            } catch (Exception e) {}
                            try {
                                quantity = (int) Double.parseDouble(ExcelUtil.getCellValueAsString(row.getCell(2)));
                            } catch (Exception e) {}
                            try {
                                alcohol = Double.parseDouble(ExcelUtil.getCellValueAsString(row.getCell(5)));
                            } catch (Exception e) {}
                            
                            p.setPrice(price);
                            p.setQuantity(quantity);
                            p.setAlcohol(alcohol);
                            
                            p.setOrigin(ExcelUtil.getCellValueAsString(row.getCell(3)));
                            p.setCapacity(ExcelUtil.getCellValueAsString(row.getCell(4)));
                            p.setDetail(ExcelUtil.getCellValueAsString(row.getCell(6)));
                            p.setTypeId(ExcelUtil.getCellValueAsString(row.getCell(7)));
                            p.setManufacturerId(ExcelUtil.getCellValueAsString(row.getCell(8)));
                            p.setCategoryId(ExcelUtil.getCellValueAsString(row.getCell(9)));
                            p.setImageUrl(ExcelUtil.getCellValueAsString(row.getCell(10)));
                            
                            // So khớp sản phẩm trong CSDL
                            Product existing = productDAO.getProductByName(name);
                            if (existing != null) {
                                p.setIsExisting(true);
                                p.setOldQuantity(existing.getQuantity());
                                p.setNewQuantity(existing.getQuantity() + quantity);
                                p.setId(existing.getId());
                                if (p.getPrice() == 0.0) {
                                    p.setPrice(existing.getPrice());
                                }
                            } else {
                                p.setIsExisting(false);
                                p.setOldQuantity(0);
                                p.setNewQuantity(quantity);
                                p.setId("P" + (System.currentTimeMillis() % 100000) + i);
                            }
                            
                            productList.add(p);
                        }
                        
                        // Lưu danh sách vào Session
                        req.getSession().setAttribute("excelImportProducts", productList);
                        
                        result.put("status", "success");
                        result.put("products", productList);
                        resp.getWriter().write(new Gson().toJson(result));
                        return;
                    } catch (Exception e) {
                        e.printStackTrace();
                        result.put("status", "error");
                        result.put("message", "File không đúng định dạng hoặc không thể phân tích dữ liệu!");
                        resp.getWriter().write(new Gson().toJson(result));
                        return;
                    }
                } else {
                    result.put("status", "error");
                    result.put("message", "Vui lòng chọn một file Excel hợp lệ!");
                    resp.getWriter().write(new Gson().toJson(result));
                    return;
                }
            } else if ("confirmImportExcel".equals(action)) {
                resp.setContentType("application/json");
                resp.setCharacterEncoding("UTF-8");
                Map<String, Object> result = new HashMap<>();
                
                try {
                    List<Product> productList = (List<Product>) req.getSession().getAttribute("excelImportProducts");
                    if (productList == null || productList.isEmpty()) {
                        result.put("status", "error");
                        result.put("message", "Không tìm thấy dữ liệu nhập Excel trong phiên làm việc của bạn!");
                        resp.getWriter().write(new Gson().toJson(result));
                        return;
                    }
                    
                    List<ProductReceiptDetail> details = new ArrayList<>();
                    BigDecimal totalAmount = BigDecimal.ZERO;
                    
                    for (Product p : productList) {
                        int importedQty = p.getQuantity();
                        if (importedQty <= 0) continue;
                        
                        if (p.getIsExisting()) {
                            // Không trực tiếp cập nhật ở đây, transaction nhập kho sẽ tự động cộng dồn số lượng tồn
                        } else {
                            // Thêm mới sản phẩm với số lượng 0 để transaction nhập kho cập nhật chính xác
                            p.setQuantity(0);
                            productDAO.insert(p);
                        }
                        
                        ProductReceiptDetail detail = new ProductReceiptDetail();
                        detail.setProductId(p.getId());
                        detail.setQuantity(importedQty);
                        BigDecimal unitPrice = BigDecimal.valueOf(p.getPrice() > 0 ? p.getPrice() : 0.0);
                        detail.setUnitPrice(unitPrice);
                        details.add(detail);
                        
                        totalAmount = totalAmount.add(unitPrice.multiply(BigDecimal.valueOf(importedQty)));
                    }
                    
                    if (!details.isEmpty()) {
                        ProductReceipt receipt = new ProductReceipt();
                        User user = (User) req.getSession().getAttribute("user");
                        receipt.setUserId(user != null ? user.getId() : 1);
                        receipt.setNote("Tự động tạo khi nhập sản phẩm hàng loạt bằng Excel.");
                        receipt.setTotalAmount(totalAmount);
                        receipt.setDetails(details);
                        
                        ProductReceiptDAO receiptDAO = JdbiConnector.get().onDemand(ProductReceiptDAO.class);
                        receiptDAO.processReceipt(receipt);
                    }
                    
                    // Dọn dẹp session
                    req.getSession().removeAttribute("excelImportProducts");
                    
                    result.put("status", "success");
                    resp.getWriter().write(new Gson().toJson(result));
                    return;
                } catch (Exception e) {
                    e.printStackTrace();
                    result.put("status", "error");
                    result.put("message", "Lỗi CSDL khi lưu trữ sản phẩm từ Excel: " + e.getMessage());
                    resp.getWriter().write(new Gson().toJson(result));
                    return;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        resp.sendRedirect("product-manager");
    }
    

}