const UserMenu = {
  mounted() {
    // Close the dropdown when clicking outside of it
    document.addEventListener('click', (event) => {
      const userMenu = document.getElementById('user-menu');
      const dropdown = document.getElementById('user-menu-dropdown');
      
      // If the click is outside the user menu
      if (userMenu && dropdown && !userMenu.contains(event.target)) {
        // Hide the dropdown
        dropdown.classList.add('hidden');
      }
    });
  }
};

export default UserMenu;
