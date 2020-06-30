import 'js-autocomplete/auto-complete.css';
import autocomplete from 'js-autocomplete';

const renderItem = function (item) {
    return `<div class="autocomplete-suggestion" data-item-id="${item.id}">${item.name}</div>`
};

const friendsSearch = function() {
  const memberId = document.getElementById('member-data').dataset.memberId;
  const searchInput = document.getElementById('friend_name');
  const friendId = document.getElementById('friend_id');

  if (memberId && friendId && searchInput) {
    searchInput.addEventListener('input', () => {
      friendId.value = '';
    });

    new autocomplete({
      selector: searchInput,
      minChars: 1,
      onSelect: (_event, _term, item) => {
        searchInput.value = item.innerText;
        friendId.value = item.dataset.itemId;
      },
      source: async (terms, suggest) => {
        const url =`/members/${memberId}/search_new_friends?search_terms=${encodeURIComponent(terms)}`;
        const results = await (await fetch(url)).json();
        suggest(results);
      },
      renderItem: renderItem,
    });
  }
};

friendsSearch();
