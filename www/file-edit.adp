<master src="fs_master">
<property name="title">Rename @title@</property>
<property name="header">Rename @title@</property>
<property name="context_bar">@context_bar@</property>

<form method=POST action=file-edit-2.tcl>
<input type=hidden name="file_id" value="@file_id@">

<p>Please enter the new name for this file:

<p><input type=text name="name" value="@name@" size=30>

<p><input type=submit value="Change Name">

</form>
