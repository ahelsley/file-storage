<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="file_select">      
      <querytext>
      
select i.item_id as file_id,
       i.name as name,
       i.live_revision,
       file_storage.get_path(i.item_id,file_storage.get_root_folder(:package_id),null) as path,
       r.mime_type as type,
       to_char(o.last_modified,'YYYY-MM-DD HH24:MI') as last_modified,
       r.content_length as content_size,
       1 as ordering_key
from   cr_items i, cr_revisions r, acs_objects o
where  i.item_id       = o.object_id
and    i.live_revision = r.revision_id (+)
and    i.parent_id     = :folder_id
and    acs_permission.permission_p(i.item_id, :user_id, 'read') = 't'
and    i.content_type = 'content_revision'
UNION
select i.item_id as file_id,
       f.label as name,
       0,
       file_storage.get_path(f.folder_id,null,null) as path,
       'Folder',
       NULL,
       0,
       0
from   cr_items i, cr_folders f
where  i.item_id   = f.folder_id
and    i.parent_id = :folder_id
and    acs_permission.permission_p(folder_id, :user_id, 'read') = 't'
order by ordering_key,name
      </querytext>
</fullquery>

 
</queryset>
