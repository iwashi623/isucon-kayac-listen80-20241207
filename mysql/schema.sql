-- // playlist_favorfite_countテーブルの作成

CREATE TABLE playlist_favorite_count (
  playlist_id INT PRIMARY KEY,
  count INT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci

create trigger playlist_favorite_insert_trigger before insert on playlist_favorite for each row insert into playlist_favorite_count (playlist_id,count) values (NEW.playlist_id, 1) on duplicate key update playlist_favorite_count.count = playlist_favorite_count.count + 1

create trigger playlist_favorite_delete_trigger before delete on playlist_favorite for each row update playlist_favorite_count set playlist_favorite_count.count = playlist_favorite_count.count - 1 where playlist_favorite_count.playlist_id = OLD.playlist_id

INSERT INTO playlist_favorite_count (`playlist_id`, `count`) SELECT `playlist_id`,count(*) FROM `playlist_favorite` GROUP BY `playlist_id`;
CREATE INDEX playlist_favorite_count_count_desc_IDX USING BTREE ON isucon_listen80.playlist_favorite_count (count DESC);
