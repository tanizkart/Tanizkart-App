const fs = require('fs');
const path = require('path');

function updateFile(filePath, transforms) {
  let content = fs.readFileSync(filePath, 'utf8');
  for (const { search, replace } of transforms) {
    if (content.includes(search)) {
      content = content.replace(search, replace);
      console.log(`[OK] Replaced in ${path.basename(filePath)}: ${search.substring(0, 40)}...`);
    } else {
      console.warn(`[WARN] Search text not found in ${path.basename(filePath)}: ${search.substring(0, 40)}...`);
    }
  }
  fs.writeFileSync(filePath, content, 'utf8');
}

// 1. HOME SCREEN
const homeTransforms = [
  {
    search: 'data-icon="shopping_bag">shopping_bag</span>\n</button>',
    replace: 'data-icon="shopping_bag">shopping_bag</span>\n</button>'
  },
  {
    search: '<button class="relative p-1.5 rounded-full bg-secondary-container/20 border border-secondary-container/40 hover:bg-secondary-container/30 text-secondary-fixed transition-colors active:scale-95">',
    replace: '<button onclick="window.location.href=\'cart.html\'" class="relative p-1.5 rounded-full bg-secondary-container/20 border border-secondary-container/40 hover:bg-secondary-container/30 text-secondary-fixed transition-colors active:scale-95 cursor-pointer">'
  },
  {
    search: '<button class="inline-flex items-center gap-1.5 bg-secondary-container text-on-secondary-fixed px-4 py-2 rounded-lg font-label-lg text-label-lg font-bold shadow-md hover:bg-secondary-fixed-dim active:scale-95 transition-all">\n<span>Shop Now</span>',
    replace: '<button onclick="window.location.href=\'listing.html\'" class="inline-flex items-center gap-1.5 bg-secondary-container text-on-secondary-fixed px-4 py-2 rounded-lg font-label-lg text-label-lg font-bold shadow-md hover:bg-secondary-fixed-dim active:scale-95 transition-all cursor-pointer">\n<span>Shop Now</span>'
  },
  {
    search: '<a class="font-label-md text-label-md text-secondary font-bold hover:underline" href="#">View All</a>',
    replace: '<a class="font-label-md text-label-md text-secondary font-bold hover:underline" href="listing.html">View All</a>'
  },
  {
    search: '<a class="font-label-md text-label-md text-secondary font-bold hover:underline" href="#">See All</a>',
    replace: '<a class="font-label-md text-label-md text-secondary font-bold hover:underline" href="listing.html">See All</a>'
  },
  {
    search: '<!-- 1. Dairy & Breakfast -->\n<div class="flex flex-col items-center text-center group cursor-pointer active:scale-95 transition-transform">',
    replace: '<!-- 1. Dairy & Breakfast -->\n<div onclick="window.location.href=\'listing.html\'" class="flex flex-col items-center text-center group cursor-pointer active:scale-95 transition-transform">'
  },
  {
    search: '<!-- Product Card 1: Amul Taaza -->\n<article class="flex-shrink-0 w-44 bg-surface-container-lowest rounded-xl p-space-sm border border-outline-variant/40 shadow-sm flex flex-col justify-between group">',
    replace: '<!-- Product Card 1: Amul Taaza -->\n<article onclick="window.location.href=\'detail.html\'" style="cursor:pointer;" class="flex-shrink-0 w-44 bg-surface-container-lowest rounded-xl p-space-sm border border-outline-variant/40 shadow-sm flex flex-col justify-between group hover:border-secondary transition-colors">'
  },
  {
    search: '<button class="bg-secondary-container hover:bg-secondary-fixed-dim text-on-secondary-fixed font-label-md text-label-md font-extrabold px-4 py-2 rounded-xl flex items-center gap-1 transition-all active:scale-95 shadow-md">\n<span>View Cart</span>',
    replace: '<button onclick="window.location.href=\'cart.html\'" class="bg-secondary-container hover:bg-secondary-fixed-dim text-on-secondary-fixed font-label-md text-label-md font-extrabold px-4 py-2 rounded-xl flex items-center gap-1 transition-all active:scale-95 shadow-md cursor-pointer">\n<span>View Cart</span>'
  },
  {
    search: '<!-- Destination 2: Categories (INACTIVE) -->\n<a class="flex flex-col items-center justify-center text-on-surface-variant dark:text-outline py-space-xs hover:text-secondary dark:hover:text-secondary-fixed-dim transition-colors active:scale-95 duration-150" href="#">',
    replace: '<!-- Destination 2: Categories (INACTIVE) -->\n<a class="flex flex-col items-center justify-center text-on-surface-variant dark:text-outline py-space-xs hover:text-secondary dark:hover:text-secondary-fixed-dim transition-colors active:scale-95 duration-150" href="listing.html">'
  }
];

// 2. PRODUCT LISTING SCREEN
const listingTransforms = [
  {
    search: '<button aria-label="Go Back" class="w-9 h-9 rounded-full flex items-center justify-center hover:bg-white/10 active:scale-95 transition-all text-white shrink-0">',
    replace: '<button onclick="window.location.href=\'home.html\'" aria-label="Go Back" class="w-9 h-9 rounded-full flex items-center justify-center hover:bg-white/10 active:scale-95 transition-all text-white shrink-0 cursor-pointer">'
  },
  {
    search: '<button aria-label="Cart 2 items" class="relative w-9 h-9 rounded-full flex items-center justify-center hover:bg-white/10 active:scale-95 transition-all text-white">',
    replace: '<button onclick="window.location.href=\'cart.html\'" aria-label="Cart 2 items" class="relative w-9 h-9 rounded-full flex items-center justify-center hover:bg-white/10 active:scale-95 transition-all text-white cursor-pointer">'
  },
  {
    search: '<!-- Card 2 (Active Stepper) -->\n<article class="bg-surface-container-lowest rounded-xl border border-[#F5A623]/40 shadow-[0_4px_12px_-2px_rgba(245,166,35,0.12)] flex flex-col justify-between p-2.5 relative group ring-1 ring-[#F5A623]/30">',
    replace: '<!-- Card 2 (Active Stepper) -->\n<article onclick="window.location.href=\'detail.html\'" style="cursor:pointer;" class="bg-surface-container-lowest rounded-xl border border-[#F5A623]/40 shadow-[0_4px_12px_-2px_rgba(245,166,35,0.12)] flex flex-col justify-between p-2.5 relative group ring-1 ring-[#F5A623]/30 hover:border-[#F5A623] transition-all">'
  },
  {
    search: '<button class="bg-[#F5A623] text-[#0A111F] font-label-md text-label-md font-bold px-3 py-1.5 rounded-xl flex items-center gap-1 hover:bg-[#feae2c] active:scale-95 transition-all shadow-sm">\n<span>View Cart</span>',
    replace: '<button onclick="window.location.href=\'cart.html\'" class="bg-[#F5A623] text-[#0A111F] font-label-md text-label-md font-bold px-3 py-1.5 rounded-xl flex items-center gap-1 hover:bg-[#feae2c] active:scale-95 transition-all shadow-sm cursor-pointer">\n<span>View Cart</span>'
  },
  {
    search: '<a class="flex flex-col items-center justify-center text-on-surface-variant dark:text-outline py-space-xs hover:text-secondary dark:hover:text-secondary-fixed-dim transition-colors active:scale-95 transition-transform duration-150" href="#home">',
    replace: '<a class="flex flex-col items-center justify-center text-on-surface-variant dark:text-outline py-space-xs hover:text-secondary dark:hover:text-secondary-fixed-dim transition-colors active:scale-95 transition-transform duration-150" href="home.html">'
  }
];

// 3. PRODUCT DETAIL SCREEN
const detailTransforms = [
  {
    search: '<button aria-label="Go back" class="w-10 h-10 rounded-full flex items-center justify-center text-on-primary hover:bg-inverse-surface transition-colors active:scale-95 duration-150">',
    replace: '<button onclick="window.location.href=\'listing.html\'" aria-label="Go back" class="w-10 h-10 rounded-full flex items-center justify-center text-on-primary hover:bg-inverse-surface transition-colors active:scale-95 duration-150 cursor-pointer">'
  },
  {
    search: '<button aria-label="Cart" class="w-10 h-10 rounded-full flex items-center justify-center relative text-on-primary hover:bg-inverse-surface transition-colors active:scale-95 duration-150">',
    replace: '<button onclick="window.location.href=\'cart.html\'" aria-label="Cart" class="w-10 h-10 rounded-full flex items-center justify-center relative text-on-primary hover:bg-inverse-surface transition-colors active:scale-95 duration-150 cursor-pointer">'
  },
  {
    search: '<button class="bg-primary-container text-on-primary font-label-lg text-label-lg font-bold px-4 py-3 rounded-full flex items-center gap-1.5 shadow-md active:scale-95 transition-transform">\n<span>View Cart</span>',
    replace: '<button onclick="window.location.href=\'cart.html\'" class="bg-primary-container text-on-primary font-label-lg text-label-lg font-bold px-4 py-3 rounded-full flex items-center gap-1.5 shadow-md active:scale-95 transition-transform cursor-pointer">\n<span>View Cart</span>'
  }
];

// 4. CART SCREEN
const cartTransforms = [
  {
    search: '<button aria-label="Go Back" class="w-9 h-9 rounded-full bg-surface-container flex items-center justify-center text-on-surface hover:bg-surface-container-high transition-colors active:scale-95" type="button">',
    replace: '<button onclick="window.location.href=\'detail.html\'" aria-label="Go Back" class="w-9 h-9 rounded-full bg-surface-container flex items-center justify-center text-on-surface hover:bg-surface-container-high transition-colors active:scale-95 cursor-pointer" type="button">'
  },
  {
    search: '<button class="w-full py-space-sm px-space-md border border-dashed border-outline-variant rounded-xl flex items-center justify-center gap-2 text-on-surface hover:bg-surface-container transition-colors active:scale-98" type="button">',
    replace: '<button onclick="window.location.href=\'listing.html\'" class="w-full py-space-sm px-space-md border border-dashed border-outline-variant rounded-xl flex items-center justify-center gap-2 text-on-surface hover:bg-surface-container transition-colors active:scale-98 cursor-pointer" type="button">'
  },
  {
    search: '<button class="flex-1 py-3 px-space-lg rounded-xl bg-secondary-container hover:bg-secondary-fixed-dim text-on-secondary-fixed font-headline-sm text-headline-sm font-bold flex items-center justify-center gap-2 shadow-md hover:shadow-lg transition-all active:scale-[0.98]" type="button">',
    replace: '<button onclick="showOrderSuccessModal()" class="flex-1 py-3 px-space-lg rounded-xl bg-secondary-container hover:bg-secondary-fixed-dim text-on-secondary-fixed font-headline-sm text-headline-sm font-bold flex items-center justify-center gap-2 shadow-md hover:shadow-lg transition-all active:scale-[0.98] cursor-pointer" type="button">'
  }
];

// Inject Order Success Modal into cart.html
function injectCartSuccessModal(filePath) {
  let content = fs.readFileSync(filePath, 'utf8');
  if (content.includes('orderSuccessModal')) return;

  const modalHtml = `
<!-- Order Placed Success Modal -->
<div id="orderSuccessModal" class="fixed inset-0 z-50 bg-black/60 backdrop-blur-sm hidden items-center justify-center p-4">
  <div class="bg-surface-container-lowest rounded-3xl max-w-sm w-full p-6 text-center shadow-2xl border border-secondary-container/40 transform transition-all scale-95 duration-200" id="orderSuccessContent">
    <div class="w-16 h-16 rounded-full bg-tertiary-fixed/30 border-2 border-[#10B981] mx-auto flex items-center justify-center mb-4 text-[#10B981] animate-bounce">
      <span class="material-symbols-outlined text-3xl" style="font-variation-settings: 'FILL' 1;">check_circle</span>
    </div>
    <span class="inline-block px-3 py-1 rounded-full bg-secondary-fixed text-on-secondary-fixed font-label-sm text-xs font-extrabold uppercase tracking-wider mb-2">Order Confirmed • #TK-84920</span>
    <h3 class="text-2xl font-extrabold text-[#0A111F] mb-1">Order Placed!</h3>
    <p class="text-sm text-slate-500 mb-4">Dispatched from Ongole Central Warehouse #04</p>
    
    <div class="bg-slate-50 rounded-2xl p-4 text-left mb-5 space-y-2 border border-slate-100 text-sm">
      <div class="flex justify-between items-center text-slate-600">
        <span>Delivery ETA:</span>
        <span class="font-bold text-[#10B981] flex items-center gap-0.5">⚡ 10–12 Mins</span>
      </div>
      <div class="flex justify-between items-center text-slate-600">
        <span>Delivery Address:</span>
        <span class="font-semibold text-slate-900 truncate max-w-[170px]">Flat 302, Lawyerpet</span>
      </div>
      <div class="flex justify-between items-center text-slate-600">
        <span>Total Paid:</span>
        <span class="font-extrabold text-slate-900">₹205 <span class="text-xs text-[#10B981]">(Saved ₹115)</span></span>
      </div>
      <div class="flex justify-between items-center text-slate-600">
        <span>Payment Method:</span>
        <span class="font-medium text-slate-800">UPI Instant 1-Click</span>
      </div>
    </div>

    <div class="space-y-2.5">
      <button onclick="window.location.href='home.html'" class="w-full py-3 rounded-xl bg-secondary-container hover:bg-secondary-fixed-dim text-[#0A111F] font-bold text-sm shadow-md transition-all active:scale-95 cursor-pointer">
        Back to Home Store
      </button>
      <button onclick="closeOrderSuccessModal()" class="w-full py-2.5 rounded-xl border border-slate-200 text-slate-700 font-semibold text-sm hover:bg-slate-50 transition-all cursor-pointer">
        View Receipt Details
      </button>
    </div>
  </div>
</div>
<script>
  function showOrderSuccessModal() {
    const modal = document.getElementById('orderSuccessModal');
    modal.classList.remove('hidden');
    modal.classList.add('flex');
  }
  function closeOrderSuccessModal() {
    const modal = document.getElementById('orderSuccessModal');
    modal.classList.add('hidden');
    modal.classList.remove('flex');
  }
</script>
`;

  content = content.replace('</body></html>', `${modalHtml}\n</body></html>`);
  fs.writeFileSync(filePath, content, 'utf8');
  console.log(`[OK] Injected Order Success Modal in ${path.basename(filePath)}`);
}

// Execute updates
console.log('--- Wiring Home Screen ---');
updateFile('y:/TanziKart/site/public/home.html', homeTransforms);
updateFile('y:/TanziKart/.stitch/designs/home.html', homeTransforms);

console.log('--- Wiring Product Listing Screen ---');
updateFile('y:/TanziKart/site/public/listing.html', listingTransforms);
updateFile('y:/TanziKart/.stitch/designs/listing.html', listingTransforms);

console.log('--- Wiring Product Detail Screen ---');
updateFile('y:/TanziKart/site/public/detail.html', detailTransforms);
updateFile('y:/TanziKart/.stitch/designs/detail.html', detailTransforms);

console.log('--- Wiring Cart & Checkout Screen ---');
updateFile('y:/TanziKart/site/public/cart.html', cartTransforms);
updateFile('y:/TanziKart/.stitch/designs/cart.html', cartTransforms);

injectCartSuccessModal('y:/TanziKart/site/public/cart.html');
injectCartSuccessModal('y:/TanziKart/.stitch/designs/cart.html');

console.log('All navigation successfully wired!');
