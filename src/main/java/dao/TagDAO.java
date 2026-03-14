package dao;

import model.Tag;

import java.util.List;

public class TagDAO extends ADAO{
    public List<Tag> getAllTags() {
        return jdbi
                .withHandle(handle -> handle.createQuery("SELECT id, tag_name AS tagName FROM tags WHERE is_delete = 0")
                        .mapToBean(Tag.class)
                        .list());
    }
}
