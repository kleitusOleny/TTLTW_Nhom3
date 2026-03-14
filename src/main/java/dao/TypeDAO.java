package dao;

import model.ProductType;

import java.util.List;

public class TypeDAO extends ADAO{
    public List<ProductType> getAllTypes() {
        return jdbi.withHandle(
                handle -> handle.createQuery("SELECT id, type_name AS typeName FROM product_types WHERE is_delete = 0")
                        .mapToBean(ProductType.class)
                        .list());
    }
}
