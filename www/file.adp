<master>
<property name="title">@title@</property>
<property name="header">@title@</property>
<property name="context">@context@</property>

<ul>
  <li>Title: @title@ <if @write_p@ true>(<a href="file-edit?file_id=@file_id@">#file-storage.edit#</a>)</if>
  <li>Owner: @owner@
<p>
  <li>#file-storage.Actions# 
  <if @show_all_versions_p@ true>
    <a href="file?file_id=@file_id@&show_all_versions_p=f">#file-storage.lt_show_only_live_versio#</a>
  </if>
  <else>
    <a href="file?file_id=@file_id@&show_all_versions_p=t">#file-storage.show_all_versions#</a>
  </else>
  <if @write_p@ true>
    | <a href="version-add?file_id=@file_id@">#file-storage.Upload_a_new_version#</a>
  </if>
    | <a href="file-copy?file_id=@file_id@">#file-storage.Copy#</a>
  <if @write_p@ true>
    | <a href="file-move?file_id=@file_id@">#file-storage.Move#</a>
  </if>
  <if @admin_p@ true and @show_administer_permissions_link_p@ true>
    | <a href="/permissions/one?object_id=@file_id@">#file-storage.lt_Modify_permissions_on#</a>
  </if>
  <if @delete_p@ true>
    | <a href="file-delete?file_id=@file_id@">#file-storage.lt_Delete_this_file_incl#</a>
  </if>
 <if @gc_comments@ not nil>
 <li>Comments on this file:
 <ul>
 @gc_comments@
 </ul>
 </if>
 <if @gc_link@ not nil>
   <li>@gc_link@
 </if>
</ul>


<table border=1 cellspacing=2 cellpadding=2>
  <tr>
    <td colspan=7>
      <if @show_all_versions_p@ true>All Versions of "@title@"</if>
      <else>Live version of "@title@"</else>.
    </td>
  </tr>
  <tr>
    <td>#file-storage.Version_filename#</td>
    <td>#file-storage.Author#</td>
    <td>#file-storage.Size_bytes#</td>
    <td>#file-storage.Type#</td>
    <td>#file-storage.Modified#</td>
    <td>#file-storage.Version_Notes#</td>
    <td>#file-storage.Actions_1#</td>
  </tr>

<multiple name=version>
  <tr>
    <td><img src="graphics/file.gif">
      <a href="download/index?version_id=@version.version_id@">@version.title@</a>
    </td>
    <td>@version.author@</td>
    <td align=right>@version.content_size_pretty@</td>
    <td>@version.type@</td>
    <td>@version.last_modified@</td>
    <td>@version.description@&nbsp;</td>
    <td>
      &nbsp;<if @version.delete_p@ true>
      <a href="version-delete?version_id=@version.version_id@">#file-storage.delete#</a> 
        <if @version.admin_p@ true and @show_administer_permissions_link_p@ true>|</if>
      </if>
      <if @version.admin_p@ true and @show_administer_permissions_link_p@ true>
        <a href="/permissions/one?object_id=@version.version_id@">#file-storage.lt_administer_permission#</a>
      </if>
    </td>
  </tr>
</multiple>

<if @version:rowcount@ eq 0>
  <tr>
    <td colspan=7><i>#file-storage.lt_There_are_no_versions#</i></td>
  </tr>
</if>
</table>


