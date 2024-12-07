CREATE INDEX playlist_ulid_IDX USING BTREE ON isucon_listen80.playlist (ulid);
CREATE INDEX song_ulid_IDX USING BTREE ON isucon_listen80.song (ulid);
CREATE INDEX playlist_favorite_favorite_user_account_created_at_desc_IDX USING BTREE ON isucon_listen80.playlist_favorite (favorite_user_account,created_at DESC);
CREATE INDEX playlist_song_playlist_id_IDX USING BTREE ON isucon_listen80.playlist_song (playlist_id);
CREATE INDEX playlist_favorite_created_at_IDX USING BTREE ON isucon_listen80.playlist_favorite (created_at);
CREATE INDEX playlist_user_account_created_at_decs_IDX USING BTREE ON isucon_listen80.playlist (user_account,created_at DESC);
CREATE INDEX user_is_ban_IDX USING BTREE ON isucon_listen80.`user` (is_ban);
