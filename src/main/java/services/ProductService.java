package services;

import dao.ProductDAO;
import model.Product;

import java.util.List;

public class ProductService {
    private static List<Product> lst = new ProductDAO().getProducts();
    public Product getProduct(String productId) {
        for (Product product:lst){
            if (product.getId().equals(productId)) return product;
        }
        return null;
    }
    
    public static int countTotalProducts() {
        return lst.size();
    }
    
    public static void appendFilterConditions(StringBuilder sql, String[] prices, String[] categories, String[] manufacturers,
                                        String[] types, String[] origins, String[] capacities, String[] tags, String keyword) {
        
        if (categories != null && categories.length > 0) {
            sql.append(" AND p.category_id IN (");
            for (int i = 0; i < categories.length; i++) {
                sql.append(categories[i]);
                if (i < categories.length - 1) {
                    sql.append(",");
                }
            }
            sql.append(")");
        }
        
        if (manufacturers != null && manufacturers.length > 0) {
            sql.append(" AND p.manufacturer_id IN (");
            for (int i = 0; i < manufacturers.length; i++) {
                sql.append(manufacturers[i]);
                if (i < manufacturers.length - 1) {
                    sql.append(",");
                }
            }
            sql.append(")");
        }
        
        if (types != null && types.length > 0) {
            sql.append(" AND p.type_id IN (");
            for (int i = 0; i < types.length; i++) {
                sql.append(types[i]);
                if (i < types.length - 1) {
                    sql.append(",");
                }
            }
            sql.append(")");
        }
        
        if (origins != null && origins.length > 0) {
            sql.append(" AND p.origin IN (");
            for (int i = 0; i < origins.length; i++) {
                // Thêm dấu nháy đơn bao quanh giá trị: 'Pháp'
                sql.append("'").append(origins[i]).append("'");
                if (i < origins.length - 1) {
                    sql.append(",");
                }
            }
            sql.append(")");
        }
        
        if (prices != null && prices.length > 0) {
            sql.append(" AND (");
            
            for (int i = 0; i < prices.length; i++) {
                String[] range = prices[i].split("-");
                
                if (i > 0) {
                    sql.append(" OR ");
                }
                
                if (range.length == 2) {
                    String min = range[0];
                    String max = range[1];
                    
                    if ("max".equalsIgnoreCase(max)) {
                        sql.append("p.price >= ").append(min);
                    } else {
                        sql.append("(p.price >= ").append(min)
                                .append(" AND p.price <= ").append(max).append(")");
                    }
                }
            }
            sql.append(")");
        }
        
        if (capacities != null && capacities.length > 0) {
            sql.append(" AND p.capacity IN (");
            for (int i = 0; i < capacities.length; i++) {
                sql.append("'").append(capacities[i]).append("'");
                if (i < capacities.length - 1) {
                    sql.append(",");
                }
            }
            sql.append(")");
        }
        
        if (tags != null && tags.length > 0) {
            sql.append(" AND p.id IN (SELECT pt.product_id FROM product_tags pt WHERE pt.tag_id IN (");
            for (int i = 0; i < tags.length; i++) {
                sql.append(tags[i]);
                if (i < tags.length - 1) {
                    sql.append(",");
                }
            }
            sql.append("))");
        }
        
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (p.product_name LIKE :keyword ")
                    .append(" OR m.manufacturer_name LIKE :keyword ")
                    .append(" OR t.type_name LIKE :keyword) ");
        }
    }
}
