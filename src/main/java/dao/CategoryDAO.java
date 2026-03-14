package dao;

import java.util.List;

public class CategoryDAO extends ADAO{
    public List<Category> getAllCategories() {
        return jdbi.withHandle(handle -> handle
                .createQuery("SELECT id, category_name AS categoryName FROM categorys WHERE is_delete = 0")
                .mapToBean(Category.class)
                .list());
    }
}
