defmodule RefugeWeb.Router do
  use RefugeWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {RefugeWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", RefugeWeb do
    pipe_through :browser

    # get "/", PageController, :home
    # # The video uses the value, `:index` unchanged from the generated code
    # # Since my code generates `:home`, I assume I use the same "page"
    # get "/bears", BearController, :home
    # # Here are the additional routes from the video
    # get "/bears/new", BearController, :new
    # get "/bears/:id", BearController, :show
    # get "/bears/:id/edit", BearController, :edit
    # post "/bears", BearController, :create
    # put "/bears:id", BearController, :update
    # patch "/bears:id", BearController, :update
    # delete "/bears:id", BearController, :delete

    # Here is the shortcut to add **all** routes at once
    resources "/bears", BearController
  end

  # Other scopes may use custom stacks.
  scope "/api", RefugeWeb do
    pipe_through :api
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:refuge, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: RefugeWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
