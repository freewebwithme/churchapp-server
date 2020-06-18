defmodule ChurchAppWeb.Schema do
  use Absinthe.Schema
  alias ChurchApp.Accounts
  alias ChurchAppWeb.Resolvers
  alias ChurchAppWeb.Schema.Middleware

  import_types(ChurchAppWeb.Schema.AccountTypes)
  import_types(ChurchAppWeb.Schema.VideoTypes)

  def middleware(middleware, _field, %{identifier: :mutation}) do
    middleware ++ [Middleware.ChangesetErrors]
  end

  def middleware(middleware, _field, _object) do
    middleware
  end

  query do
    @desc "List all user(ADMIN)"
    field :list_users, list_of(:user) do
      middleware(Middleware.AdminOnly)
      resolve(&Resolvers.Admin.list_users/3)
    end

    @desc "Get user(ADMIN)"
    field :get_user, :user do
      arg(:id, non_null(:string))
      middleware(Middleware.AdminOnly)
      resolve(&Resolvers.Admin.get_user/3)
    end

    @desc "Get the currently signed in user"
    field :me, :user do
      resolve(&Resolvers.Accounts.me/3)
    end

    @desc "Verify token for reset password"
    field :verify_token, :verify_token_response do
      arg(:token, non_null(:string))
      resolve(&Resolvers.Accounts.verify_token_for_reset_password/3)
    end

    @desc "Get church"
    field :get_church, :church do
      arg(:uuid, :string)
      resolve(&Resolvers.Accounts.get_church/3)
    end

    @desc "Search Videos"
    field :search_videos, :video_search_response do
      arg(:channel_id, non_null(:string))
      arg(:order, non_null(:string))
      arg(:max_results, non_null(:integer))
      arg(:query, non_null(:string))
      arg(:next_page_token, :string)
      resolve(&Resolvers.YoutubeResolver.search_videos/3)
    end

    # TODO: Currently using search.list api which consumes 100 per request
    @desc "Get live streaming video"
    field :get_live_streaming, :video_search_response do
      arg(:channel_id, non_null(:string))
      resolve(&Resolvers.YoutubeResolver.search_live_streaming_videos/3)
    end

    @desc "Get all playlists"
    field :playlists, list_of(:playlist) do
      arg(:channel_id, :string)
      resolve(&Resolvers.YoutubeResolver.get_all_playlists/3)
    end

    @desc "Get all playlist items"
    field :playlist_items, :video_search_response do
      arg(:church_id, :string)
      arg(:next_page_token, :string)
      arg(:playlist_id, :string)
      resolve(&Resolvers.YoutubeResolver.get_playlist_items/3)
    end
  end

  mutation do
    @desc "Update Keys Info(ADMIN)"
    field :update_key_info, :church do
      arg(:church_id, :string)
      arg(:google_api_key, :string)
      arg(:stripe_secret_key, :string)
      arg(:stripe_publishable_key, :string)
      arg(:onesignal_app_id, :string)
      arg(:onesignal_api_key, :string)
      middleware(Middleware.AdminOnly)
      resolve(&Resolvers.Admin.update_key_info/3)
    end

    @desc "Password reset start, sending a link by email"
    field :password_reset_start, :password_reset_response do
      arg(:email, :string)
      arg(:recaptcha_value, :string)
      resolve(&Resolvers.Accounts.password_reset_start/3)
    end

    @desc "Send push notification"
    field :send_push, :notification_response do
      arg(:church_id, :string)
      arg(:title, :string)
      arg(:message, :string)
      resolve(&Resolvers.OnesignalResolver.send_push/3)
    end

    @desc "Make a payment using payment id from client"
    field :make_offering, :payment_intent do
      arg(:payment_method_id, :string)
      arg(:email, :string)
      arg(:amount, :string)
      arg(:church_id, :string)

      resolve(&Resolvers.StripeResolver.make_offering/3)
    end

    @desc "user sign up"
    field :sign_up, :session do
      arg(:email, :string)
      arg(:password, :string)
      arg(:name, :string)
      arg(:recaptcha_value, non_null(:string))
      resolve(&Resolvers.Accounts.sign_up/3)
    end

    @desc "User sign in"
    field :sign_in, :session do
      arg(:email, :string)
      arg(:password, :string)
      resolve(&Resolvers.Accounts.sign_in/3)
    end

    @desc "Update user info"
    field :update_me, :user do
      arg(:user_id, non_null(:string))
      arg(:name, non_null(:string))
      arg(:email, non_null(:string))
      arg(:phone_number, :string)
      resolve(&Resolvers.Accounts.update_me/3)
    end

    @desc "Change password"
    field :change_password, :user do
      arg(:email, non_null(:string))
      arg(:current_password, non_null(:string))
      arg(:new_password, non_null(:string))
      resolve(&Resolvers.Accounts.change_password/3)
    end

    @desc "Reset Password"
    field :reset_password, :user do
      arg(:email_from_token, non_null(:string))
      arg(:email_from_input, non_null(:string))
      arg(:new_password, non_null(:string))
      resolve(&Resolvers.Accounts.reset_password/3)
    end

    @desc "create church for user"
    field :create_church, :church do
      arg(:name, non_null(:string))
      arg(:channel_id, non_null(:string))
      arg(:intro, non_null(:string))
      arg(:user_id, non_null(:string))
      arg(:address_line_one, :string)
      arg(:address_line_two, :string)
      arg(:phone_number, :string)
      arg(:email, :string)
      arg(:website, :string)

      resolve(&Resolvers.Accounts.create_church/3)
    end

    @desc "Update church info"
    field :update_church, :church do
      arg(:church_id, non_null(:string))
      arg(:name, non_null(:string))
      arg(:channel_id, non_null(:string))
      arg(:intro, non_null(:string))
      arg(:address_line_one, :string)
      arg(:address_line_two, :string)
      arg(:phone_number, :string)
      arg(:email, :string)
      arg(:website, :string)

      resolve(&Resolvers.Accounts.update_church/3)
    end

    @desc "Update service info"
    field :update_service_info, :church do
      arg(:church_id, non_null(:string))
      arg(:schedules, :string)

      resolve(&Resolvers.Accounts.update_service_info/3)
    end

    @desc "Create Employee"
    field :create_employee, :employee do
      arg(:name, non_null(:string))
      arg(:position, non_null(:string))
      arg(:profile_image, :string)
      arg(:church_id, non_null(:string))
      arg(:order, non_null(:integer))

      resolve(&Resolvers.Accounts.create_employee/3)
    end

    @desc "Update Employee"
    field :update_employee, :employee do
      arg(:id, non_null(:id))
      arg(:name, non_null(:string))
      arg(:position, non_null(:string))
      arg(:profile_image, :string)
      arg(:church_id, non_null(:string))
      arg(:order, non_null(:integer))

      resolve(&Resolvers.Accounts.update_employee/3)
    end

    @desc "Delete Employee"
    field :delete_employee, :employee do
      arg(:id, non_null(:id))
      arg(:church_id, non_null(:string))

      resolve(&Resolvers.Accounts.delete_employee/3)
    end

    @desc "Create news"
    field :create_news, :news do
      arg(:church_id, non_null(:string))
      arg(:content, non_null(:string))

      resolve(&Resolvers.Accounts.create_news/3)
    end

    @desc "Update news"
    field :update_news, :news do
      arg(:id, non_null(:id))
      arg(:church_id, non_null(:string))
      arg(:content, non_null(:string))

      resolve(&Resolvers.Accounts.update_news/3)
    end

    @desc "Delete news"
    field :delete_news, :news do
      arg(:id, non_null(:id))
      arg(:church_id, non_null(:string))

      resolve(&Resolvers.Accounts.delete_news/3)
    end

    @desc "Refetch Latest videos from YouTube"
    field :refetch_latest_videos, list_of(:latest_videos) do
      arg(:church_id, non_null(:string))
      arg(:user_id, non_null(:string))

      resolve(&Resolvers.YoutubeResolver.refetch_latest_videos/3)
    end
  end

  object :notification_response do
    field :id, :string
    field :recipients, :integer
  end

  object :session do
    field :token, :string
    field :user, :user
  end

  object :presigned_url do
    field :url, :string
  end

  object :payment_intent do
    field :id, :string
    field :amount_received, :string
    field :receipt_url, :string
    field :status, :string
  end

  object :password_reset_response do
    field :recipient, :string
    field :message, :string
  end

  object :verify_token_response do
    field :success, :boolean
    field :email, :string
    field :message, :string
  end

  def context(ctx) do
    loader =
      Dataloader.new()
      |> Dataloader.add_source(Accounts, Accounts.data())

    Map.put(ctx, :loader, loader)
  end

  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end
end
