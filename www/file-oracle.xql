<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="file_info">      
      <querytext>
      
	select person.name(o.creation_user) as owner,
       		i.name as title,
       		r.title as name,
       		acs_permission.permission_p(:file_id,:user_id,'write') as write_p,
       		acs_permission.permission_p(:file_id,:user_id,'delete') as delete_p,
       		acs_permission.permission_p(:file_id,:user_id,'admin') as admin_p
	from   acs_objects o, cr_revisions r, cr_items i
	where  o.object_id = :file_id
	and    i.item_id   = o.object_id
	and    r.revision_id = i.live_revision
      </querytext>
</fullquery>

<fullquery name="version_info">      
      <querytext>

	select  r.title,
       		r.revision_id as version_id,
       		person.name(o.creation_user) as author,
       		r.mime_type as type,
                to_char(o.last_modified,'YYYY-MM-DD HH24:MI:SS') as last_modified_ansi,
       		r.description,
       		acs_permission.permission_p(r.revision_id,:user_id,'admin') as admin_p,
       		acs_permission.permission_p(r.revision_id,:user_id,'delete') as delete_p,
       		r.content_length as content_size
	from   acs_objects o, cr_revisions r, cr_items i
	where  o.object_id = r.revision_id
	and    acs_permission.permission_p(r.revision_id, :user_id, 'read') = 't'
	and    r.item_id = i.item_id
	and    r.item_id = :file_id
	$show_versions order by last_modified desc

      </querytext>
</fullquery> 

<partialquery name="show_all_versions">      
      <querytext>

      </querytext>
</partialquery> 	

<partialquery name="show_live_version">      
      <querytext>

	and r.revision_id = i.live_revision

      </querytext>
</partialquery> 	

 
</queryset>
