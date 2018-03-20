# Quality-Assurance-Apex-Plug-In

<h3>What is it?</h3>

Even with written guidelines setup for your APEX project, it still is a challenge to get all your </br>developers aligned to live these guidelines.  This little plugin helps by showing on the page which</br> guidelines where not followed properly, so the developer can address these.


The QA Plugin uses the APEX metadata repository to check the guidelines you implement. Several </br>checks come with the plugin, but since each project is different, you might want to extend the checks made.


The plugin can be placed on any page in your APEX application, but we recommend to place it on the global page. 

<h3>Information</h3>
<a href="http://de.slideshare.net/OliverLemm/the-apex-qa-plugin" target="_blank">Presentation of Quality Assurance Plugin APEX </a>

<h3>Demo</h3>
<p>Just click on the link below to see the plugin in action:</p>

<p><a href="https://apex.mt-ag.com/apex/f?p=278" target="_blank">Demo</a></p>

# Installation

<h3>Install the Plugin</h3>

<p>Go into the APEX workspace, where you like to install the QA Plugin and import the file /APEX/region_type_plugin_com_mtag_olemm_qa_region.sql as a region plugin.
Afterwards, go into your favorite SQL-tool or into the SQL workshop within APEX and install the database objects. Use the script plugin_qa_install.sql to install these
</p>

<p>Optionally, you can import some demo checks which are included in the file /DML/plugin_qa_rules.sql.</p>

<h3>Run the Plugin</h3>
<p>Go to your application and choose a page where you would like to run the checks and add the plugin. We recommended that you add the plugin on the Global Page, so it is executed automatically on every page.</p>

<h3>Security</h3>
<p>To make sure that only developers see the outcome of the checks, we recommend to add the following  PL/SQL condition for the QA Plugin:</p>

<p>apex_application.g_edit_cookie_session_id IS NOT NULL 
</p>
