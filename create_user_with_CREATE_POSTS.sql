insert ignore into GROUPS (UUID, `NAME`) VALUES ((SELECT UUID() FROM dual), 'createPosts');
SET @createPosts_group_id := (select GROUP_ID from GROUPS where `NAME`='createPosts');
SET @createPosts_group_sid := concat('usergroup:',@createPosts_group_id);
insert ignore into USERS (UUID, USERNAME, ENCODED_USERNAME, EMAIL, PASSWORD, ROLE, SALT, ENABLED) VALUES
  ((SELECT UUID() FROM dual), 'post_creator', 'post_creator', 'post_creator@jtalks.org', MD5('qwerty'), 'USER_ROLE', '',true);
insert ignore into JC_USER_DETAILS (USER_ID, REGISTRATION_DATE, POST_COUNT) values
  ((select ID from USERS where USERNAME = 'post_creator'), NOW(), 0);
insert ignore into GROUP_USER_REF select @createPosts_group_id, ID from USERS where USERNAME = 'post_creator';
insert into acl_sid(principal, sid) values (0, @createPosts_group_sid);
SET @createPosts_group_sid_id := (select id from acl_sid where sid=@createPosts_group_sid);
set @createPosts_group_object_identity=@branches_count + 4;
insert ignore into acl_object_identity values
  (@createPosts_group_object_identity, @group_acl_class, @createPosts_group_id, NULL, 1, 1);
insert into acl_entry (acl_object_identity, ace_order, sid, mask, granting, audit_success, audit_failure)
  select BRANCH_ID, 1021, @createPosts_group_sid_id, @VIEW_TOPICS_MASK, 1, 0, 0 from BRANCHES;
insert into acl_entry (acl_object_identity, ace_order, sid, mask, granting, audit_success, audit_failure)
  select BRANCH_ID, 1022, @createPosts_group_sid_id, @CREATE_POSTS_MASK, 1, 0, 0 from BRANCHES;