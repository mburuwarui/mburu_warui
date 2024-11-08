defmodule AmboseliWeb.PageController do
  use AmboseliWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.

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
          "Design and development of in-game economies, player-to-player trading systems, and virtual asset exchanges for gaming marketplaces."
      },
      %{
        image:
          "https://cdn.dribbble.com/userupload/3233220/file/original-e80767b5947df65a0f1ab4dab4964679.png?compress=1&resize=1024x768",
        title: "Multi-Program Loyalty and Rewards Systems",
        description:
          "Design and development of loyalty and rewards systems with multi-program support, real-time points balance updates, and automated reward distributions."
      },
      %{
        image:
          "https://cdn.dribbble.com/users/1644453/screenshots/14748860/media/25f53296059b741ac1c083be9f41745b.png?compress=1&resize=1000x750&vertical=top",
        title: "Department-Wise Budget Tracking and Financial Allocation",
        description:
          "Design and development of enterprise resource management systems with department-wise budget tracking, project-based financial allocation, and real-time expense monitoring."
      },
      %{
        image:
          "https://cdn.dribbble.com/users/878428/screenshots/17307425/media/01782a518148ce7ef2e790473c888b1f.png?compress=1&resize=1000x750&vertical=top",
        title: "Escrow Account Management and Split Payments",
        description:
          "Design and development of marketplace payment systems with escrow account management, split payments, multi-party transactions, and real-time settlement."
      },
      %{
        image:
          "https://cdn.dribbble.com/users/1930709/screenshots/11466872/media/e50b0f02160a77397eb4a76782d23966.png?compress=1&resize=1000x750&vertical=top",
        title: "Virtual Asset Exchanges and Trading Systems",
        description:
          "Design and development of virtual asset exchanges and trading systems for gaming marketplaces, including in-game economies and player-to-player trading systems."
      },
      %{
        image:
          "https://cdn.dribbble.com/users/1644453/screenshots/14403641/media/21e305eb9c8255b6e3367f0ca52c6668.png?compress=1&resize=1000x750&vertical=top",
        title: "Automated Reward Distributions and Real-Time Points Balance Updates",
        description:
          "Design and development of loyalty and rewards systems with automated reward distributions, real-time points balance updates, and multi-program support."
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

    render(conn, :home,
      services: services,
      categories: categories,
      projects: projects,
      posts: posts
    )
  end
end
