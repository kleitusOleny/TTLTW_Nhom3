package controller;

import dao.ManufacturerDAO;
import dao.TagDAO;
import dao.TypeDAO;

import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

@WebListener
public class HeaderController implements ServletContextListener {
    
    @Override
    public void contextInitialized(ServletContextEvent sce) {
        ServletContext context = sce.getServletContext();
        
        TypeDAO typeDAO = new TypeDAO();
        ManufacturerDAO manufacturerDAO = new ManufacturerDAO();
        TagDAO tagDAO = new TagDAO();

        context.setAttribute("globalListTypes", typeDAO.getTop6Types());
        context.setAttribute("globalListManufacturers", manufacturerDAO.getTop6Manufacturers());
        context.setAttribute("globalListTags", tagDAO.getTop6Tags());
        context.setAttribute("globalListRegions", manufacturerDAO.getTop6Regions());
    }
    
}