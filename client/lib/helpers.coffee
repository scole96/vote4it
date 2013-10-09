Handlebars.registerHelper('formatDate', (date, format) ->
  date = moment(date)
  date.format(format)
)

Handlebars.registerHelper('getEmailByUser', (user) ->
  if user
    getEmail user
)
Handlebars.registerHelper('getUserName', (id) ->
  Meteor.users.findOne(id)?.profile.name
)
Handlebars.registerHelper('getEmailById', (id) ->
  user = Meteor.users.findOne(id)
  if user
    getEmail user
)

Handlebars.registerHelper('inspect', (object) ->
  console.log object
)