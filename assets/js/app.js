// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;

// Custom JS functions
//
// Dark Mode
function darkExpected() {
  return (
    localStorage.theme === "dark" ||
    (!("theme" in localStorage) &&
      window.matchMedia("(prefers-color-scheme: dark)").matches)
  );
}

function initDarkMode() {
  // On page load or when changing themes, best to add inline in `head` to avoid FOUC
  if (darkExpected()) {
    document.documentElement.classList.add("dark");
    document
      .getElementById("icon")
      .setAttribute(
        "d",
        "M10 2a1 1 0 011 1v1a1 1 0 11-2 0V3a1 1 0 011-1zm4 8a4 4 0 11-8 0 4 4 0 018 0zm-.464 4.95l.707.707a1 1 0 001.414-1.414l-.707-.707a1 1 0 00-1.414 1.414zm2.12-10.607a1 1 0 010 1.414l-.706.707a1 1 0 11-1.414-1.414l.707-.707a1 1 0 011.414 0zM17 11a1 1 0 100-2h-1a1 1 0 100 2h1zm-7 4a1 1 0 011 1v1a1 1 0 11-2 0v-1a1 1 0 011-1zM5.05 6.464A1 1 0 106.465 5.05l-.708-.707a1 1 0 00-1.414 1.414l.707.707zm1.414 8.486l-.707.707a1 1 0 01-1.414-1.414l.707-.707a1 1 0 011.414 1.414zM4 11a1 1 0 100-2H3a1 1 0 000 2h1z",
      );
    document.getElementById("icon").classList.add("sun-icon");
  } else {
    document.documentElement.classList.remove("dark");
    document
      .getElementById("icon")
      .setAttribute(
        "d",
        "M17.293 13.293A8 8 0 016.707 2.707a8.001 8.001 0 1010.586 10.586z",
      );
    document.getElementById("icon").classList.remove("sun-icon");
  }
}
// Header Scroll effect
window.addEventListener("DOMContentLoaded", () => {
  window.addEventListener("scroll", function () {
    const header = document.querySelector("header");
    const headerHeight = header.offsetHeight;
    const scrollPosition = window.pageYOffset;

    // Check if dark mode is enabled
    const isDarkMode = darkExpected();

    if (scrollPosition >= headerHeight) {
      if (isDarkMode) {
        header.classList.remove("bg-zinc-800");
        header.classList.add("bg-transparent");
      } else {
        header.classList.remove("bg-zinc-500");
        header.classList.add("bg-transparent");
      }
    } else {
      if (isDarkMode) {
        header.classList.remove("bg-transparent");
        header.classList.add("bg-zinc-800");
      } else {
        header.classList.remove("bg-transparent");
        header.classList.add("bg-zinc-500");
      }
    }
  });
});

window.addEventListener("toggle-darkmode", (e) => {
  const header = document.querySelector("header");

  if (darkExpected()) {
    header.classList.remove("bg-zinc-800");
    header.classList.add("bg-zinc-500");
    localStorage.theme = "light";
  } else {
    header.classList.remove("bg-zinc-500");
    header.classList.add("bg-zinc-800");
    localStorage.theme = "dark";
  }

  initDarkMode();
});

initDarkMode();
