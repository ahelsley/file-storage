--
-- packages/file-storage/sql/postgresql/file-storage-drop.sql
--
-- @author Kevin Scaldeferri (kevin@arsdigita.com)
-- @creation-date 6 Now 2000
-- @cvs-id $Id$
--
-- drop script for file-storage
--

--
-- content repository is set up to cascade, so we should just have to 
-- delete the root folders
--
create function inline_0() 
returns integer as '
declare
	rec_root_folder		record;
begin

    for rec_root_folder in 
        select package_id
	from fs_root_folders
    loop
        -- JS: The RI constraints will cause acs_objects__delete to fail
	-- JS: So I changed this to apm_package__delete
        PERFORM apm_package__delete(rec_root_folder.package_id);
    end loop;

    return 0;

end;' language 'plpgsql';

select inline_0();
drop function inline_0();

drop function fs_package_items_delete_trig();
drop trigger fs_package_items_delete_trig on fs_root_folders;

drop function fs_root_folder_delete_trig();
drop trigger fs_root_folder_delete_trig on fs_root_folders;

drop table fs_root_folders;
select drop_package('file_storage');

