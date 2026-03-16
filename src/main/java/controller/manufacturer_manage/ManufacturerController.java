package controller.manufacturer_manage;

import dao.ManufacturerDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Manufacturer;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "ManufacturerController", value = "/manage-manufacturer")
public class ManufacturerController extends HttpServlet {
    
    ManufacturerDAO manufacturerDAO = new ManufacturerDAO();
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        List<Manufacturer> list = manufacturerDAO.getAllManufacturers();
        req.setAttribute("manufacturers", list);
        req.getRequestDispatcher("admin/manage_manufacturer.jsp").forward(req, resp);
    }
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        
        if ("add".equals(action)) {
            String name = req.getParameter("name");
            String location = req.getParameter("location");
            
            Manufacturer m = new Manufacturer();
            m.setManufacturerName(name);
            m.setLocation(location);
            
            manufacturerDAO.insert(m);
        } else if ("delete".equals(action)) {
            int id = Integer.parseInt(req.getParameter("id"));
            manufacturerDAO.delete(id);
        } else if ("edit".equals(action)) {
            String idStr = req.getParameter("id");
            String name = req.getParameter("name");
            String location = req.getParameter("location");
            
            if (idStr != null && !idStr.isEmpty()) {
                Manufacturer m = new Manufacturer();
                m.setId(Integer.parseInt(idStr));
                m.setManufacturerName(name);
                m.setLocation(location);
                
                manufacturerDAO.update(m); // Gọi hàm update
            }
        }
        resp.sendRedirect("manage-manufacturer");
    }
}