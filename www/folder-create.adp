<master src="fs_master">
<property name="title">Create New Folder</property>
<property name="context_bar">@context_bar@</property>


<form method=POST action=folder-create-2>
<input type=hidden name=parent_id value="@parent_id@">

<table>
 <tr>
  <td align=right>Folder Name:</td>
  <td><input type=text name=folder_name size=20></td>
 </tr>
 <tr>
  <td>&nbsp;</td>
  <td><input type=submit value="Create"></td>
 </tr>
</table>

</form>