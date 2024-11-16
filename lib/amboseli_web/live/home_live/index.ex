defmodule AmboseliWeb.HomeLive.Index do
  use AmboseliWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <section>
      <div class="relative grid w-full bg-zinc-500 dark:bg-zinc-800 h-96 lg:h-[32rem] place-items-center">
        <div class="flex flex-col items-center mx-auto text-center">
          <h1 class="text-4xl font-semibold text-white md:text-6xl">Mburu Warui</h1>

          <p class="mt-6 text-lg leading-5 text-white">
            Software Engineer & Architect of Scalable OLTP Applications
          </p>

          <a href="#about" class="mt-8 cursor-pointer animate-bounce">
            <svg
              width="53"
              height="53"
              viewBox="0 0 53 53"
              fill="none"
              xmlns="http://www.w3.org/2000/svg"
            >
              <circle cx="27" cy="26" r="18" stroke="white" stroke-width="2" />
              <path
                d="M22.41 23.2875L27 27.8675L31.59 23.2875L33 24.6975L27 30.6975L21 24.6975L22.41 23.2875Z"
                fill="white"
              />
            </svg>
          </a>
        </div>
      </div>

      <svg
        class="fill-zinc-500 dark:fill-zinc-800"
        viewBox="0 0 1440 57"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
      >
        <path d="M1440 0H0V57C720 0 1440 57 1440 57V0Z" />
      </svg>
    </section>

    <section class="container px-6 py-8 mx-auto lg:py-16 " id="about">
      <div class="lg:flex lg:items-center lg:-mx-4">
        <div class="lg:w-1/2 lg:px-4">
          <h3 class="text-xl font-medium text-gray-800 dark:text-zinc-200 md:text-2xl lg:text-3xl">
            Building Scalable OLTP Applications and Digital Experiences
          </h3>

          <p class="mt-6 text-gray-500 dark:text-zinc-400">
            I design and develop scalable applications, focusing on gaming marketplaces, in-game economies, player-to-player trading systems, virtual asset exchanges, loyalty and rewards systems, enterprise resource management, and marketplace payment systems.
          </p>

          <button class="flex items-center mt-8 -mx-2 text-zinc-500 dark:text-zinc-900">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="w-8 h-8 mx-1"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
              stroke-width="2"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z"
              />
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
              />
            </svg>
            <p class="mx-1 font-semibold">PLAY VIDEO</p>
          </button>
        </div>

        <div class="mt-8 lg:w-1/2 lg:px-4 lg:mt-0">
          <img
            class="object-cover w-full rounded-xl h-96"
            src="https://images.unsplash.com/photo-1516131206008-dd041a9764fd?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=880&q=80"
            alt="Video thumbnail"
          />
        </div>
      </div>
    </section>

    <section class="container px-6 py-8 mx-auto lg:py-16">
      <div class="grid grid-cols-1 gap-8 xl:gap-12 md:grid-cols-2 xl:grid-cols-3">
        <%= for service <- @services do %>
          <div class="p-8 space-y-3 border-2 border-zinc-400 dark:border-zinc-600 rounded-lg">
            <span class="inline-block text-zinc-500 dark:text-zinc-400">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="w-8 h-8"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d={service.icon}
                />
              </svg>
            </span>

            <h1 class="text-2xl font-semibold text-gray-700 dark:text-gray-200 capitalize">
              <%= service.title %>
            </h1>

            <p class="text-gray-500 dark:text-gray-400">
              <%= service.description %>
            </p>
          </div>
        <% end %>
      </div>
    </section>

    <section class="container px-6 py-8 mx-auto lg:py-16">
      <h3 class="text-xl font-medium text-gray-800 dark:text-zinc-200 md:text-2xl lg:text-3xl">
        Explore My Expertise
      </h3>

      <div class="flex items-center py-6 mt-4 -mx-2 overflow-x-auto whitespace-nowrap">
        <%= for category <- @categories do %>
          <button class=" inline-flex px-4 mx-2 duration-300 transition-colors hover:bg-zinc-500/70 hover:text-white text-gray-500 dark:text-zinc-200 focus:outline-none py-0.5 cursor-pointer rounded-2xl">
            <%= category %>
          </button>
        <% end %>
      </div>

      <div class="grid grid-cols-1 gap-10 mt-10 md:grid-cols-2 lg:grid-cols-3">
        <%= for project <- @projects do %>
          <.link href={project.link} class="flex-shrink-0">
            <div class="relative overflow-hidden rounded-lg group">
              <img
                class="object-cover object-center w-full h-64 rounded-lg lg:h-80 transition-all duration-300 ease-in-out group-hover:scale-110"
                src={project.image}
                alt={project.title}
              />
              <div class="absolute inset-0 bg-black bg-opacity-0 transition-opacity duration-300 group-hover:bg-opacity-20">
              </div>
            </div>

            <h4 class="my-2 text-xl font-semibold text-gray-900 dark:text-zinc-100 hover:text-blue-600 dark:hover:text-blue-400 transition-colors">
              <%= project.title %>
            </h4>

            <p class="text-gray-500 dark:text-zinc-400 hover:text-gray-700 dark:hover:text-zinc-300 transition-colors">
              <%= project.description %>
            </p>
          </.link>
        <% end %>
      </div>
    </section>

    <section class="container px-6 py-8 mx-auto lg:py-16">
      <h3 class="text-xl font-medium text-gray-800 dark:text-zinc-200 md:text-2xl lg:text-3xl">
        Recent Blog Posts
      </h3>

      <div class="grid grid-cols-1 gap-8 mt-8 md:mt-10 md:grid-cols-2 xl:grid-cols-3">
        <%= for post <- @posts do %>
          <div>
            <div class="relative overflow-hidden rounded-lg group">
              <img
                class="object-cover object-center w-full h-64 rounded-lg lg:h-80 transition-all duration-300 ease-in-out group-hover:scale-110"
                src={post.image}
                alt=""
              />
              <div class="absolute inset-0 bg-black bg-opacity-0 transition-opacity duration-300 group-hover:bg-opacity-20">
              </div>
              <div class="absolute bottom-0 flex p-3 bg-white dark:bg-zinc-900 ">
                <img
                  class="object-cover object-center w-10 h-10 rounded-full"
                  src={post.author_image}
                  alt=""
                />

                <div class="mx-4">
                  <h1 class="text-sm text-gray-700 dark:text-zinc-200"><%= post.author %></h1>
                  <p class="text-sm text-gray-500 dark:text-zinc-400"><%= post.author_title %></p>
                </div>
              </div>
            </div>

            <h1 class="mt-6 text-xl font-semibold text-gray-800 dark:text-zinc-200">
              <%= post.title %>
            </h1>

            <hr class="w-32 my-6 text-zinc-500 dark:text-zinc-400" />

            <p class="text-sm text-gray-500 dark:text-zinc-400">
              <%= post.description %>
            </p>

            <a href={post.link} class="inline-block mt-4 text-zinc-500 underline hover:text-zinc-400">
              Read more
            </a>
          </div>
        <% end %>
      </div>
    </section>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :home, _params) do
    services = [
      %{
        icon:
          "M17.657 18.657A8 8 0 016.343 7.343S7 9 9 10c0-2 .5-5 2.986-7C14 5 16.09 5.777 17.656 7.343A7.975 7.975 0 0120 13a7.975 7.975 0 01-2.343 5.657z",
        title: "Gaming Marketplaces",
        description:
          "I design and develop gaming marketplaces, in-game economies, player-to-player trading systems, and virtual asset exchanges."
      },
      %{
        icon:
          "M11 4a2 2 0 114 0v1a1 1 0 001 1h3a1 1 0 011 1v3a1 1 0 01-1 1h-1a2 2 0 100 4h1a1 1 0 011 1v3a1 1 0 01-1 1h-3a1 1 0 01-1-1v-1a2 2 0 10-4 0v1a1 1 0 01-1 1H7a1 1 0 01-1-1v-3a1 1 0 00-1-1H4a2 2 0 110-4h1a1 1 0 001-1V7a1 1 0 011-1h3a1 1 0 001-1V4z",
        title: "Loyalty and Rewards Systems",
        description:
          "I design and develop loyalty and rewards systems, including points and rewards tracking, multi-program support, real-time points balance updates, and automated reward distributions."
      },
      %{
        icon:
          "M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z",
        title: "Enterprise Resource Management",
        description:
          "I design and develop enterprise resource management systems, including internal account management, department-wise budget tracking, project-based financial allocation, and real-time expense monitoring."
      },
      %{
        icon:
          "M11 4a2 2 0 114 0v1a1 1 0 001 1h3a1 1 0 011 1v3a1 1 0 01-1 1h-1a2 2 0 100 4h1a1 1 0 011 1v3a1 1 0 01-1 1h-3a1 1 0 01-1-1v-1a2 2 0 10-4 0v1a1 1 0 01-1 1H7a1 1 0 01-1-1v-3a1 1 0 00-1-1H4a2 2 0 110-4h1a1 1 0 001-1V7a1 1 0 011-1h3a1 1 0 001-1V4z",
        title: "Marketplace Payment Systems",
        description:
          "I design and develop marketplace payment systems, including escrow account management, split payments, multi-party transactions, and real-time settlement."
      }
    ]

    categories = [
      "All",
      "Gaming Marketplaces",
      "Loyalty and Rewards Systems",
      "Enterprise Resource Management",
      "Marketplace Payment Systems"
    ]

    projects = [
      %{
        image:
          "https://cdn.dribbble.com/users/1644453/screenshots/17056773/media/00509f74e765da294440886db976943a.png?compress=1&resize=1000x750&vertical=top",
        title: "In-Game Economies and Trading Systems",
        description:
          "Design and development of in-game economies, player-to-player trading systems, and virtual asset exchanges for gaming marketplaces.",
        link: "#"
      },
      %{
        image:
          "https://cdn.dribbble.com/userupload/3233220/file/original-e80767b5947df65a0f1ab4dab4964679.png?compress=1&resize=1024x768",
        title: "Multi-Program Loyalty and Rewards Systems",
        description:
          "Design and development of loyalty and rewards systems with multi-program support, real-time points balance updates, and automated reward distributions.",
        link: "#"
      },
      %{
        image:
          "https://cdn.dribbble.com/users/1644453/screenshots/14748860/media/25f53296059b741ac1c083be9f41745b.png?compress=1&resize=1000x750&vertical=top",
        title: "Department-Wise Budget Tracking and Financial Allocation",
        description:
          "Design and development of enterprise resource management systems with department-wise budget tracking, project-based financial allocation, and real-time expense monitoring.",
        link: "#"
      },
      %{
        image:
          "https://cdn.dribbble.com/users/878428/screenshots/17307425/media/01782a518148ce7ef2e790473c888b1f.png?compress=1&resize=1000x750&vertical=top",
        title: "Escrow Account Management and Split Payments",
        description:
          "Design and development of marketplace payment systems with escrow account management, split payments, multi-party transactions, and real-time settlement.",
        link: "#"
      },
      %{
        image:
          "https://cdn.dribbble.com/users/1930709/screenshots/11466872/media/e50b0f02160a77397eb4a76782d23966.png?compress=1&resize=1000x750&vertical=top",
        title: "Virtual Asset Exchanges and Trading Systems",
        description:
          "Design and development of virtual asset exchanges and trading systems for gaming marketplaces, including in-game economies and player-to-player trading systems.",
        link: "#"
      },
      %{
        image:
          "https://cdn.dribbble.com/users/1644453/screenshots/14403641/media/21e305eb9c8255b6e3367f0ca52c6668.png?compress=1&resize=1000x750&vertical=top",
        title: "Automated Reward Distributions and Real-Time Points Balance Updates",
        description:
          "Design and development of loyalty and rewards systems with automated reward distributions, real-time points balance updates, and multi-program support.",
        link: "#"
      }
    ]

    posts = [
      %{
        image:
          "https://images.unsplash.com/photo-1624996379697-f01d168b1a52?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1470&q=80",
        author_image:
          "https://cdn.dribbble.com/users/1436669/screenshots/15006128/media/5f91264b3b56cc452cb2bba2535bccdd.png?compress=1&resize=1000x750&vertical=top",
        author: "Tom Hank",
        author_title: "Creative Director",
        title: "What do you want to know about UI",
        description:
          "Lorem ipsum dolor sit amet consectetur adipisicing elit. Blanditiis fugit dolorum amet dolores praesentium, alias nam? Tempore",
        link: "#"
      },
      %{
        image:
          "https://images.unsplash.com/photo-1590283603385-17ffb3a7f29f?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1470&q=80",
        author_image:
          "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=880&q=80",
        author: "arthur melo",
        author_title: "Creative Director",
        title: "All the features you want to know",
        description:
          "Lorem ipsum dolor sit amet consectetur adipisicing elit. Blanditiis fugit dolorum amet dolores praesentium, alias nam? Tempore",
        link: "#"
      },
      %{
        image:
          "https://images.unsplash.com/photo-1597534458220-9fb4969f2df5?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1374&q=80",
        author_image:
          "https://images.unsplash.com/photo-1531590878845-12627191e687?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=764&q=80",
        author: "Amelia. Anderson",
        author_title: "Lead Developer",
        title: "Which services you get from Meraki UI",
        description:
          "Lorem ipsum dolor sit amet consectetur adipisicing elit. Blanditiis fugit dolorum amet dolores praesentium, alias nam? Tempore",
        link: "#"
      }
    ]

    socket
    |> assign(:services, services)
    |> assign(:categories, categories)
    |> assign(:projects, projects)
    |> assign(:posts, posts)
  end

  defp page_title(:home), do: "Mburu Warui"
end
