package dao;

import model.Product;
import services.ProductService;

import java.util.Collections;
import java.util.List;

public class ProductDAO extends ADAO {

    public List<Product> listProduct() {
        return jdbi.withHandle(handle -> handle.createQuery(
                "SELECT " +
                        "p.id, " +
                        "p.product_name, " +
                        "p.slug, " +
                        "p.price, " +
                        "p.capacity, " +
                        "p.alcohol, " +
                        "p.origin, " +
                        "p.quantity, " +
                        "p.detail, " +
                        "p.create_at, " +
                        "p.update_at, " +
                        "p.is_delete, " +
                        "(SELECT url_img FROM p_img WHERE product_id = p.id LIMIT 1) AS imageUrl, " +
                        "t.type_name AS typeId, " +
                        "m.manufacturer_name AS manufacturerId, " +
                        "c.category_name AS categoryId " +
                        "FROM products p " +
                        "LEFT JOIN product_types t ON p.type_id = t.id " +
                        "LEFT JOIN manufacturers m ON p.manufacturer_id = m.id " +
                        "LEFT JOIN categorys c ON p.category_id = c.id ")
                .mapToBean(Product.class)
                .list());
    }

    public List<String> getProductIdsByCategoryIds(List<String> categoryIds) {
        if (categoryIds == null || categoryIds.isEmpty()) {
            return Collections.emptyList();
        }
        return jdbi.withHandle(handle -> handle.createQuery("""
                SELECT id FROM products
                WHERE is_delete = 0 AND category_id IN (<categoryIds>)
                """)
                .defineList("categoryIds", categoryIds)
                .mapTo(String.class)
                .list());
    }

    public List<String> getProductIdsByManufacturerIds(List<String> manufacturerIds) {
        if (manufacturerIds == null || manufacturerIds.isEmpty()) {
            return Collections.emptyList();
        }
        return jdbi.withHandle(handle -> handle.createQuery("""
                SELECT id FROM products
                WHERE is_delete = 0 AND manufacturer_id IN (<manufacturerIds>)
                """)
                .defineList("manufacturerIds", manufacturerIds)
                .mapTo(String.class)
                .list());
    }

    public List<String> filterExistingProductIds(List<String> productIds) {
        if (productIds == null || productIds.isEmpty()) {
            return Collections.emptyList();
        }
        return jdbi.withHandle(handle -> handle.createQuery("""
                SELECT id FROM products
                WHERE is_delete = 0 AND id IN (<productIds>)
                """)
                .defineList("productIds", productIds)
                .mapTo(String.class)
                .list());
    }

    public List<Product> getProducts() {
        return jdbi.withHandle(handle -> handle.createQuery("SELECT " +
                "p.id, p.product_name, p.slug, p.price, p.capacity, p.alcohol, p.origin, p.quantity, p.create_at," +
                "t.type_name AS typeId, " +
                "m.manufacturer_name AS manufacturerId, " +
                "d.discount_value AS discount_value, " +
                "d.discount_type AS discount_type, " +

                "(SELECT url_img FROM p_img WHERE product_id = p.id LIMIT 1) AS imageUrl, " +

                "(SELECT AVG(ct.star) " +
                " FROM evaluates e " +
                " JOIN ct_evaluates ct ON e.evaluate_id = ct.id " +
                " WHERE e.product_id = p.id AND ct.is_delete IS NULL) AS rating, " +

                "(SELECT COUNT(*) FROM evaluates e JOIN ct_evaluates ct ON e.evaluate_id = ct.id WHERE e.product_id = p.id AND ct.is_delete IS NULL) AS totalReviews "
                +
                "FROM products p " +
                "LEFT JOIN product_types t ON p.type_id = t.id " +
                "LEFT JOIN manufacturers m ON p.manufacturer_id = m.id " +
                "LEFT JOIN dis_process dp ON p.id = dp.product_id AND dp.is_delete = 0 " +
                "LEFT JOIN discounts d ON dp.discount_id = d.id AND d.is_active = 1 AND d.is_delete = 0 AND NOW() BETWEEN d.discount_from AND d.discount_to "
                +
                "WHERE p.is_delete = 0 ")
                .mapToBean(Product.class)
                .list());

    }

    public List<Product> getProducts(int limit, int offset, String sort) {
        String order = "ORDER BY price ";
        switch (sort) {
            case "price-asc":
                order += "ASC ";
                break;
            case "price-desc":
                order += "DESC ";
                break;
            case "rating":
                order += "DESC "; // Giả sử cột là rating
                break;
            default:
                order = ""; // Mặc định
                break;
        }

        String sql = "SELECT " +
                "p.id, p.product_name, p.slug, p.price, p.capacity, p.alcohol, p.origin, p.quantity, p.create_at, " +
                "t.type_name AS typeId, " +
                "m.manufacturer_name AS manufacturerId, " +
//                "d.discount_value AS discount_value, " +
//                "d.discount_type AS discount_type, " +

                "(SELECT url_img FROM p_img WHERE product_id = p.id LIMIT 1) AS imageUrl, " +

                "(SELECT AVG(ct.star) " +
                " FROM evaluates e " +
                " JOIN ct_evaluates ct ON e.evaluate_id = ct.id " +
                " WHERE e.product_id = p.id AND ct.is_delete IS NULL) AS rating, " +

                "(SELECT COUNT(*) FROM evaluates e JOIN ct_evaluates ct ON e.evaluate_id = ct.id WHERE e.product_id = p.id AND ct.is_delete IS NULL) AS totalReviews "
                +
                "FROM products p " +
                "LEFT JOIN product_types t ON p.type_id = t.id " +
                "LEFT JOIN manufacturers m ON p.manufacturer_id = m.id " +
//                "LEFT JOIN dis_process dp ON p.id = dp.product_id AND dp.is_delete = 0 " +
//                "LEFT JOIN discounts d ON dp.discount_id = d.id AND d.is_active = 1 AND d.is_delete = 0 AND NOW() BETWEEN d.discount_from AND d.discount_to " +
                "WHERE p.is_delete = 0 " +
                order +
                "LIMIT :limit OFFSET :offset";
        return jdbi.withHandle(handle -> handle.createQuery(sql)
                .bind("limit", limit)
                .bind("offset", offset)
                .mapToBean(Product.class)
                .list());
    }

    public int countTotalProducts() {
        return jdbi.withHandle(handle -> handle.createQuery("SELECT COUNT(*) FROM products WHERE is_delete = 0")
                .mapTo(Integer.class).stream().findFirst().orElse(0));
    }

    public Product getProductById(String id) {
        return jdbi.withHandle(handle -> handle.createQuery(
                "SELECT " +
                        "p.id, p.product_name, p.slug, p.price, p.capacity, p.alcohol, p.origin, p.quantity, p.detail, p.create_at, p.update_at, p.is_delete, "
                        +
                        "t.type_name AS typeId, " +
                        "m.manufacturer_name AS manufacturerId, " +
                        "c.category_name AS categoryId, " +
                        "d.discount_value AS discount_value, " +
                        "d.discount_type AS discount_type, " +
                        "(SELECT url_img FROM p_img WHERE product_id = p.id LIMIT 1) AS imageUrl " +

                        "FROM products p " +
                        "LEFT JOIN product_types t ON p.type_id = t.id " +
                        "LEFT JOIN manufacturers m ON p.manufacturer_id = m.id " +
                        "LEFT JOIN categorys c ON p.category_id = c.id " +
                        "LEFT JOIN dis_process dp ON p.id = dp.product_id AND dp.is_delete = 0 " +
                        "LEFT JOIN discounts d ON dp.discount_id = d.id AND d.is_active = 1 AND d.is_delete = 0 AND NOW() BETWEEN d.discount_from AND d.discount_to "
                        +
                        "WHERE p.id = :id AND p.is_delete = 0")
                .bind("id", id)
                .mapToBean(Product.class)
                .findFirst().orElse(null));
    }

    public List<Product> getRelatedProducts() {
        return jdbi.withHandle(handle -> handle.createQuery(
                "SELECT " +
                        "p.id, p.product_name, p.slug, p.price, p.capacity, p.alcohol, p.origin, p.detail, p.create_at, p.update_at, p.is_delete, "
                        +
                        "t.type_name AS typeId, " +
                        "m.manufacturer_name AS manufacturerId, " +
                        "c.category_name AS categoryId, " +
                        "d.discount_value AS discount_value, " +
                        "d.discount_type AS discount_type, " +
                        "(SELECT url_img FROM p_img WHERE product_id = p.id LIMIT 1) AS imageUrl " +
                        "FROM products p " +
                        "LEFT JOIN product_types t ON p.type_id = t.id " +
                        "LEFT JOIN manufacturers m ON p.manufacturer_id = m.id " +
                        "LEFT JOIN categorys c ON p.category_id = c.id " +
                        "LEFT JOIN dis_process dp ON p.id = dp.product_id AND dp.is_delete = 0 " +
                        "LEFT JOIN discounts d ON dp.discount_id = d.id AND d.is_active = 1 AND d.is_delete = 0 AND NOW() BETWEEN d.discount_from AND d.discount_to "
                        +
                        "WHERE p.is_delete = 0 " +
                        "ORDER BY RAND() LIMIT 5")
                .mapToBean(Product.class)
                .list());
    }
    
    // Lấy danh sách xuất xứ
    public List<String> getAllOrigins() {
        return jdbi.withHandle(handle -> handle
                .createQuery("SELECT DISTINCT origin FROM products WHERE is_delete = 0 AND origin IS NOT NULL")
                .mapTo(String.class)
                .list());
    }

    // Lấy danh sách dung tích
    public List<String> getAllCapacities() {
        return jdbi.withHandle(handle -> handle
                .createQuery("SELECT DISTINCT capacity FROM products WHERE is_delete = 0 AND capacity IS NOT NULL")
                .mapTo(String.class)
                .list());
    }

    // Lấy danh sách đã lọc
    public List<Product> filterProducts(String[] prices, String[] categories, String[] manufacturers, String[] types,
            String[] origins, String[] capacities, String[] tags, String keyword, int limit, int offset, String sort) {

        String order = "ORDER BY price ";
        switch (sort) {
            case "price-asc":
                order += "ASC ";
                break;
            case "price-desc":
                order += "DESC ";
                break;
            case "rating":
                order += "DESC "; // Giả sử cột là rating
                break;
            default:
                order = ""; // Mặc định
                break;
        }
        StringBuilder sql = new StringBuilder(
                "SELECT p.id, p.product_name, p.slug, p.price, p.capacity, p.alcohol, p.origin, p.quantity, " +
                        "t.type_name AS typeId, m.manufacturer_name AS manufacturerId, " +
                        "d.discount_value AS discount_value, d.discount_type AS discount_type, " +
                        "(SELECT url_img FROM p_img WHERE product_id = p.id LIMIT 1) AS imageUrl, " +
                        "(SELECT AVG(ct.star) FROM evaluates e JOIN ct_evaluates ct ON e.evaluate_id = ct.id WHERE e.product_id = p.id AND ct.is_delete IS NULL) AS rating, "
                        +
                        "(SELECT COUNT(*) FROM evaluates e JOIN ct_evaluates ct ON e.evaluate_id = ct.id WHERE e.product_id = p.id AND ct.is_delete IS NULL) AS totalReviews "
                        +
                        "FROM products p " +
                        "LEFT JOIN product_types t ON p.type_id = t.id " +
                        "LEFT JOIN manufacturers m ON p.manufacturer_id = m.id " +
                        "LEFT JOIN dis_process dp ON p.id = dp.product_id AND dp.is_delete = 0 " +
                        "LEFT JOIN discounts d ON dp.discount_id = d.id AND d.is_active = 1 AND d.is_delete = 0 AND NOW() BETWEEN d.discount_from AND d.discount_to "
                        +
                        "WHERE p.is_delete = 0 ");

        ProductService.appendFilterConditions(sql, prices, categories, manufacturers, types, origins, capacities, tags, keyword);

        sql.append(" LIMIT :limit OFFSET :offset");

        return jdbi.withHandle(handle -> {
            // Tạo query
            var query = handle.createQuery(sql.toString())
                    .bind("limit", limit)
                    .bind("offset", offset);

            // Bind tham số keyword nếu có
            if (keyword != null && !keyword.trim().isEmpty()) {
                query.bind("keyword", "%" + keyword.trim() + "%");
            }

            return query.mapToBean(Product.class).list();
        });
    }

    public int countFilteredProducts(String[] prices, String[] categories, String[] manufacturers, String[] types,
            String[] origins, String[] capacities, String[] tags, String keyword) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM products p " +
                        "LEFT JOIN product_types t ON p.type_id = t.id " +
                        "LEFT JOIN manufacturers m ON p.manufacturer_id = m.id " +
                        "WHERE p.is_delete = 0 ");
        
        ProductService.appendFilterConditions(sql, prices, categories, manufacturers, types, origins, capacities, tags, keyword);

        return jdbi.withHandle(handle -> {
            var query = handle.createQuery(sql.toString());
            if (keyword != null && !keyword.trim().isEmpty()) {
                query.bind("keyword", "%" + keyword.trim() + "%");
            }
            return query.mapTo(Integer.class).findOnly();
        });
    }

    // Phương thức private hỗ trợ nối chuỗi SQL cho lọc


    public double getMaxPrice() {
        return jdbi.withHandle(handle -> handle.createQuery("SELECT MAX(price) FROM products WHERE is_delete = 0")
                .mapTo(Double.class)
                .findOnly());
    }

    public int getQuantity(String productId) {
        return jdbi.withHandle(handle -> handle.createQuery("SELECT quantity FROM products WHERE id = :id")
                .bind("id", productId)
                .mapTo(Integer.class)
                .findFirst().orElse(0));
    }

    public boolean updateQuantity(String productId, int quantity) {
        return jdbi.withHandle(handle -> handle.createUpdate("UPDATE products SET quantity = :quantity WHERE id = :id")
                .bind("quantity", quantity)
                .bind("id", productId)
                .execute() > 0);
    }

    /**
     * Lấy tất cả sản phẩm (wrapper cho getProducts())
     * Sử dụng cho modal "Áp dụng mã giảm giá"
     */
    public List<Product> getAllProducts() {
        return getProducts();
    }

    /**
     * Lấy danh sách sản phẩm theo category ID
     * Sử dụng cho modal "Áp dụng mã giảm giá"
     */
    public List<Product> getProductsByCategoryId(String categoryId) {
        return jdbi.withHandle(handle -> handle.createQuery(
                "SELECT " +
                        "p.id, p.product_name, p.slug, p.price, p.capacity, p.alcohol, p.origin, p.quantity, " +
                        "t.type_name AS typeId, " +
                        "m.manufacturer_name AS manufacturerId, " +
                        "c.category_name AS categoryId, " +
                        "d.discount_value AS discount_value, " +
                        "d.discount_type AS discount_type, " +
                        "(SELECT url_img FROM p_img WHERE product_id = p.id LIMIT 1) AS imageUrl " +
                        "FROM products p " +
                        "LEFT JOIN product_types t ON p.type_id = t.id " +
                        "LEFT JOIN manufacturers m ON p.manufacturer_id = m.id " +
                        "LEFT JOIN categorys c ON p.category_id = c.id " +
                        "LEFT JOIN dis_process dp ON p.id = dp.product_id AND dp.is_delete = 0 " +
                        "LEFT JOIN discounts d ON dp.discount_id = d.id AND d.is_active = 1 AND d.is_delete = 0 AND NOW() BETWEEN d.discount_from AND d.discount_to "
                        +
                        "WHERE p.category_id = :categoryId AND p.is_delete = 0")
                .bind("categoryId", categoryId)
                .mapToBean(Product.class)
                .list());
    }

    /**
     * Lấy danh sách sản phẩm theo manufacturer ID
     * Sử dụng cho modal "Áp dụng mã giảm giá"
     */
    public List<Product> getProductsByManufacturerId(String manufacturerId) {
        return jdbi.withHandle(handle -> handle.createQuery(
                "SELECT " +
                        "p.id, p.product_name, p.slug, p.price, p.capacity, p.alcohol, p.origin, p.quantity, " +
                        "t.type_name AS typeId, " +
                        "m.manufacturer_name AS manufacturerId, " +
                        "c.category_name AS categoryId, " +
                        "d.discount_value AS discount_value, " +
                        "d.discount_type AS discount_type, " +
                        "(SELECT url_img FROM p_img WHERE product_id = p.id LIMIT 1) AS imageUrl " +
                        "FROM products p " +
                        "LEFT JOIN product_types t ON p.type_id = t.id " +
                        "LEFT JOIN manufacturers m ON p.manufacturer_id = m.id " +
                        "LEFT JOIN categorys c ON p.category_id = c.id " +
                        "LEFT JOIN dis_process dp ON p.id = dp.product_id AND dp.is_delete = 0 " +
                        "LEFT JOIN discounts d ON dp.discount_id = d.id AND d.is_active = 1 AND d.is_delete = 0 AND NOW() BETWEEN d.discount_from AND d.discount_to "
                        +
                        "WHERE p.manufacturer_id = :manufacturerId AND p.is_delete = 0")
                .bind("manufacturerId", manufacturerId)
                .mapToBean(Product.class)
                .list());
    }

    public void insert(Product p) {
        jdbi.useHandle(handle -> {
            handle.createUpdate(
                    "INSERT INTO products (id, product_name, slug, type_id, price, capacity, alcohol, origin, manufacturer_id, category_id, detail, quantity, create_at, is_delete) "
                            +
                            "VALUES (:id, :productName, :slug, :typeId, :price, :capacity, :alcohol, :origin, :manufacturerId, :categoryId, :detail, :quantity, NOW(), 0)")
                    .bindBean(p)
                    .execute();
        });
    }

    // 3. Xóa sản phẩm
    public void delete(String id) {
        jdbi.useHandle(handle -> handle.createUpdate("UPDATE products SET is_delete = 1 WHERE id = :id")
                .bind("id", id)
                .execute());
    }

    public void update(Product p) {
        jdbi.useHandle(handle -> {
            handle.createUpdate("UPDATE products SET product_name=:productName, slug=:slug, type_id=:typeId, " +
                    "price=:price, capacity=:capacity, alcohol=:alcohol, origin=:origin, " +
                    "manufacturer_id=:manufacturerId, category_id=:categoryId, detail=:detail, " +
                    "quantity=:quantity, update_at=NOW() " +
                    "WHERE id=:id")
                    .bindBean(p)
                    .execute();
        });
    }

    public List<Product> countOutOfStocks() {
        return jdbi
                .withHandle(handle -> handle.createQuery("SELECT * FROM products WHERE quantity <= 5 AND is_delete = 0")
                        .mapToBean(Product.class)
                        .list());
    }
    
}