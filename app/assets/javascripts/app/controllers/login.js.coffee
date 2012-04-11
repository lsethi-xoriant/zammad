$ = jQuery.sub()
Note = App.Note

$.fn.item = ->
  elementID   = $(@).data('id')
  elementID or= $(@).parents('[data-id]').data('id')
  Note.find(elementID)

class Index extends App.Controller
  events:
    'submit #login': 'login',
    'click #register': 'register'
    
  constructor: ->
    super
    @title 'Sign in'
    @render()
    @navupdate '#login'

  render: (data = {}) ->
    @html App.view('login')(item: data)
    if $(@el).find('[name="username"]').val()
      $(@el).find('[name="username"]').focus()
  
  login: (e) ->
    e.preventDefault()
    e.stopPropagation();

    @log 'submit', $(e.target)
    @username = $(e.target).find('[name="username"]').val()
    @password = $(e.target).find('[name="password"]').val()
#    @log @username, @password 
    
    # session create with login/password
    auth = new App.Auth
    auth.login(
      data: {
        username: @username,
        password: @password,
      },
      success: @success
      error: @error,
    )
 
  success: (data, status, xhr) =>
    @log 'login:success', data

    # set avatar
    if !data.session.image
      data.session.image = 'http://placehold.it/48x48'

    # update config
    for key, value of data.config
      window.Config[key] = value

    # store user data
    for key, value of data.session
      window.Session[key] = value

    # refresh default collections
    for key, value of data.default_collections
      App[key].refresh( value, options: { clear: true } )

    Spine.trigger 'navrebuild', data.session

    # add notify
    Spine.trigger 'notify:removeall'
    Spine.trigger 'notify', {
      type: 'success',
      msg: 'Login successfully! Have a nice day!', 
    }
    
    # redirect to #
    if window.Config['requested_url'] isnt ''
      @navigate window.Config['requested_url']
      
      # reset
      window.Config['requested_url'] = ''
    else
      @navigate '#/'

  error: (xhr, statusText, error) =>
    console.log 'login:error'
    
    # add notify
    Spine.trigger 'notify:removeall'
    Spine.trigger 'notify', {
      type: 'warning',
      msg: 'Wrong Username and Password combination.', 
    }
    
    # rerender login page
    @render(
      msg: 'Wrong Username and Password combination.', 
      username: @username
    )

Config.Routes['login'] = Index

#class App.Login extends App.Router
#  routes:
#    'login': Index
#Config.Controller.push App.Login