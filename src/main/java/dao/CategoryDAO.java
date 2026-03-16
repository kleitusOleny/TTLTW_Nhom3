package dao;

import model.Category;

import java.util.List;

public class CategoryDAO extends ADAO{
    public List<Category> getAllCategories() {
        return jdbi.withHandle(handle -> handle
                .createQuery("SELECT id, category_name AS categoryName FROM categorys WHERE is_delete = 0")
                .mapToBean(Category.class)
                .list());
    }
    
    public int insert(Category c) {
        String query = "INSERT INTO categorys (category_name, slug, create_at, is_delete) VALUES (:categoryName, :slug, NOW(), 0)";
        return jdbi.withHandle(handle ->
                handle.createUpdate(query)
                        .bindBean(c)
                        .execute());
    }
    
    public int delete(String id) {
        String query = "UPDATE categorys SET is_delete = 1 WHERE id = :id";
        return jdbi.withHandle(handle ->
                handle.createUpdate(query)
                        .bind("id", id)
                        .execute());
    }
    
    public int update(Category c) {
        String query = "UPDATE categorys SET category_name = :categoryName, slug = :slug WHERE id = :id";
        return jdbi.withHandle(handle ->
                handle.createUpdate(query)
                        .bind("id", c.getId())
                        .bind("categoryName", c.getCategoryName())
                        .bind("slug", c.getSlug())
                        .execute());
    }
}
