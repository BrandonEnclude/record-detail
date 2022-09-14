# Installable Metadata Template
This is a template for creating metadata repositories with a "Deploy to Salesforce" button, courtesy of [afawsett](https://github.com/afawcett/githubsfdeploy)

## How to Use
- Clone template
- Populate the force-app\main\default directory with metadata
- Update the URL of the button below, replacing {REPOSITORY-NAME} with the name of your Github repo

## Deploy
<a href="https://githubsfdeploy.herokuapp.com?owner=EncludeLtd&repo={REPOSITORY-NAME}&ref=main">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>