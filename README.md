# Quality-Assurance-Apex-Plug-In

<h3>What is it?</h3>
With that Plugin you can define Rules based on SQL Queries, which check your Application.
These Rules can use the APEX Repository (APEX Views) to check Items, Regions, Dynamic Actions and every other object can be accessed in your database.

Further on you can also define rules based on your Table Content or based on the Oracle Metadata tables like user_objects.
The Region Plugin can be placed on any page in your APEX Application. The best Page to place the plugin is on the Global Page. Then the Plugin checks on every Page which is run your rule and prints out all objects which are in conflict with your rules.
Equal to the Advisor you can directly use a link to edit the APEX Element and solve the problem.
<p>This Beta Release is combined to the presentation on KScope 2014.
Further information and a demo Case will be given in summer 2014 after the conference.</p>

<h3>Information</h3>
<a href="http://de.slideshare.net/OliverLemm/the-apex-qa-plugin" target="_blank">Presentation of Quality Assurance Plugin APEX </a>

<h3>Demo</h3>
<p>In the Link below you can try out and see the Plugin<br>
!!! Login is: !!!<br>
<a href="http://apex.mt-ag.com/apex/f?p=278:LOGIN_DESKTOP::::::" target="_blank">Demo</a></p>

#Installation
<h3>Install the Plugin</h3>

<p>Go into the APEX Workspace, where you like to install the Plugin and import the /APEX/region_type_plugin_com_mtag_olemm_qa_region.sql file as an Region Plugin.<br>
Afterwards go into your SQL-Tool or into the SQL Workshop and install the database objects.</p>

<p>Use the Script 
plugin_qa_install.sql to install the Objects.<br>
At last you can import some demo rules which are included in the file
/DML/plugin_qa_rules.sql</p>

<h3>Run the Plugin:</h3>
<p>Go to your application and choose a page where you would like to run the checks. It's recommed to use the Global Page,
for checking every Page and add a Region -&gt; Plugin -&gt; Quality Assurance - Region to this page.</p>

<h3>Security</h3>
<p>It's also recommed to use a condition, that only developers can see the region. Use this PL/SQL Condition</p>

<p>APEX_Application.g_edit_cookie_session_id IS NOT NULL
then only People who are logged in into the APEX Workspace can see this region. </p>
