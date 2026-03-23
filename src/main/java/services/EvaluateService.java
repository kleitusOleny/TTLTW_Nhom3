package services;

import dao.CTEvaluateDAO;
import dao.EvaluateDAO;
import dao.ProductDAO;
import model.CTEvaluates;
import model.Evaluates;
import model.Product;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

public class EvaluateService {
    private EvaluateDAO evaluateDAO;
    private ProductDAO productDAO ;
    private CTEvaluateDAO ctEvaluateDAO;

    public EvaluateService() {
        this.evaluateDAO = new EvaluateDAO();
        this.productDAO =new ProductDAO();
        this.ctEvaluateDAO = new CTEvaluateDAO();
    }

    public List<Evaluates> getUserReviewHistory(Integer id) {
       return evaluateDAO.getByUserId(id);
    }


}
