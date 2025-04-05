const MobileMenu = {
  mounted() {
    // Get references to the menu elements
    const menuButton = document.getElementById("mobile-menu-button");
    const mobileMenu = document.getElementById("mobile-menu");
    const closedIcon = document.getElementById("menu-closed-icon");
    const openIcon = document.getElementById("menu-open-icon");

    // Toggle icons when menu state changes
    this.handleEvent("toggle", () => {
      const isHidden = mobileMenu.classList.contains("hidden");
      
      // Toggle icon visibility
      if (isHidden) {
        closedIcon.classList.add("hidden");
        openIcon.classList.remove("hidden");
      } else {
        closedIcon.classList.remove("hidden");
        openIcon.classList.add("hidden");
      }
    });
  }
};

export default MobileMenu;
