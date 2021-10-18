```
.____    ________    __________      __________ __________ ____  __.
|    |   \_____  \  /  _____/  \    /  \_____  \\______   \    |/ _|
|    |    /   |   \/   \  __\   \/\/   //   |   \|       _/      <
|    |___/    |    \    \_\  \        //    |    \    |   \    |  \
|_______ \_______  /\______  /\__/\  / \_______  /____|_  /____|__ \
        \/       \/        \/      \/          \/       \/        \/

By: Shane Breining
```

# About

This helpful bash script, while simple and having **minimal validation**
(user beware), is intended to help make it easier and quicker to log working
hours on tickets in Atlassian's Jira software. In a few words, it sends a cURL
request with the time specified for the ticket specified.

# Setup

### Information Needed

It requires 3 pieces of information:

1. Your login (username or email)
2. Your company domain (ex: `google.atlassian.net`)
3. A Jira token

### Acquiring Your Jira Token

Photos of the following steps are in `/photos/jira_token` and are nubmered
accordingly with the following steps.

1. While in Jira, click on your pofile icon on the top right of the page.
2. Select `Account Settings` from the drop down, which will open a new tab
   in your browser (It may require login again).
3. On the left side navbar, click on `Security`.
4. Click on `Create and managae API tokens`.
5. Click on the button `Create API token`.
6. Give it a label, this is arbitrary.
7. When the next box pops up, `Your new API token`, copy that to clip board
   as you will not be able to access that value again and will have to go back to
   step 5.

### Applying Gathered Info

Now, place your gathered information in the script at the top where the
variables are assigned.

![apply](/photos/apply_info/apply.jpg)

# Example Usage

### Execution

The following, where `logwork` represents the execution of the script.

```
1. logwork -t DEV-101 -w 5h30m
2. logwork -t DEV-101 -w 45m
3. logwork -t DEV-101 -w 7h
```

The following is how to vew the help message, and examples in the console:

```
1. logwork -h
```

### Response

When a response comes back, the only piece that will display on the console is
the HTTP Status Code. However, this script will create a `logwork/` directory
in the `/tmp/` directory to store the most recent request for the day. Each
request will overwrite the previous logs. Examples can be seen in
`/photos/requests/`

Here is the success:

![success](/photos/requests/success.jpg)
