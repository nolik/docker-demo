package com.example.dockerdemo.repository;

import com.example.dockerdemo.model.Image;
import org.springframework.data.repository.PagingAndSortingRepository;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;

@RepositoryRestResource(collectionResourceRel = "images", path = "images")
public interface ImageRepository extends PagingAndSortingRepository<Image, Long> {
}
