# Mburu Warui Lab Journal

<!--toc:start-->

- [Mburu Warui Lab Journal](#mburu-warui-lab-journal)
  - [Learn more](#learn-more)
  - [iex update user role](#iex-update-user-role)
  - [iex bulk create products](#iex-bulk-create-products)
  <!--toc:end-->

My personal website.

To start your Phoenix server:

- Run `mix setup` to install and setup dependencies
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

- Official website: <https://www.phoenixframework.org/>
- Guides: <https://hexdocs.pm/phoenix/overview.html>
- Docs: <https://hexdocs.pm/phoenix>
- Forum: <https://elixirforum.com/c/phoenix-forum>
- Source: <https://github.com/phoenixframework/phoenix>

## iex update user role

```elixir
{:ok, user} = Amboseli.Accounts.User |> Ash.Query.filter(email == "mburu@warui.cc") |> Ash.read(authorize?: false)

user = List.first(user)

changeset = Ash.Changeset.new(user) |> Ash.Changeset.for_update(:update, %{role: :author})

Ash.update!(changeset, authorize?: false)


```

## iex bulk create products

```elixir
{:ok, user} = Ash.get!(Amboseli.Accounts.User, %{email: "mburu@warui.cc"}, authorize?: false)

Ash.bulk_create!(
  [
    %{
      title: "Product 1",
      description: "Product 1 description",
      price: 100,
      visibility: :public,
    },
    %{
      title: "Product 2",
      description: "Product 2 description",
      price: 200,
      visibility: :public,
    }
  ],
  :create,
  actor: user,
  notify?: true
)
```
