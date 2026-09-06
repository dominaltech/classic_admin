// CLASSIC PWA ADMIN — CORE SYSTEM CONTROLLER
// Classic Collection Solapur (classicsolapur.com)

(function () {
  'use strict';

  // Helper: Get initialized Supabase client
  function getClient() {
    return window.adminSupabase || (typeof window.initAdminSupabase === 'function' ? window.initAdminSupabase() : null);
  }

  // Toast notification
  window.showAdminToast = function (message) {
    let toast = document.querySelector('#adminToast');
    if (!toast) {
      toast = document.createElement('div');
      toast.id = 'adminToast';
      toast.className = 'admin-toast';
      document.body.appendChild(toast);
    }
    toast.textContent = message;
    toast.classList.add('show');
    setTimeout(() => {
      toast.classList.remove('show');
    }, 3200);
  };

  // Modal helpers
  window.openAdminModal = function (id) {
    const modal = document.getElementById(id);
    if (modal) modal.classList.add('active');
  };

  window.closeAdminModal = function (id) {
    const modal = document.getElementById(id);
    if (modal) modal.classList.remove('active');
  };

  // Auth gate check
  window.checkAdminAuth = async function () {
    const client = getClient();
    if (!client) return null;

    try {
      const { data: { session } } = await client.auth.getSession();
      if (!session || !session.user) {
        console.warn('No active admin session found.');
        return null;
      }

      // Verify is_admin on profile
      const { data: profile } = await client
        .from('profiles')
        .select('id, name, is_admin')
        .eq('id', session.user.id)
        .maybeSingle();

      return { user: session.user, profile };
    } catch (err) {
      console.error('Admin auth check failed:', err);
      return null;
    }
  };

  // Direct Supabase Storage Image Upload
  window.uploadProductImage = async function (file) {
    const client = getClient();
    if (!client) throw new Error('Supabase client not initialized');

    const fileExt = file.name.split('.').pop();
    const fileName = `${Date.now()}_${Math.random().toString(36).substring(2, 9)}.${fileExt}`;
    const filePath = `products/${fileName}`;

    const { error: uploadError } = await client.storage
      .from('product-images')
      .upload(filePath, file, {
        cacheControl: '3600',
        upsert: false
      });

    if (uploadError) {
      throw uploadError;
    }

    const { data: { publicUrl } } = client.storage
      .from('product-images')
      .getPublicUrl(filePath);

    return publicUrl;
  };

  // ==========================================
  // 1. DASHBOARD OVERVIEW & ANALYTICS
  // ==========================================
  window.loadDashboardStats = async function () {
    const client = getClient();
    if (!client) return;

    try {
      // 1. Orders and Revenue
      const { data: orders, error: ordersErr } = await client.from('orders').select('id, total_amount, status, created_at');
      if (!ordersErr && orders) {
        document.getElementById('totalOrdersVal').textContent = orders.length;
        const totalRevenue = orders
          .filter(o => o.status !== 'cancelled')
          .reduce((sum, o) => sum + Number(o.total_amount || 0), 0);
        document.getElementById('totalRevenueVal').textContent = `₹${totalRevenue.toLocaleString('en-IN')}`;
      }

      // 2. Products count
      const { count: productsCount } = await client.from('products').select('*', { count: 'exact', head: true });
      if (document.getElementById('totalProductsVal')) {
        document.getElementById('totalProductsVal').textContent = productsCount || 0;
      }

      // 3. Materials count
      const { count: materialsCount } = await client.from('materials').select('*', { count: 'exact', head: true });
      if (document.getElementById('totalMaterialsVal')) {
        document.getElementById('totalMaterialsVal').textContent = materialsCount || 0;
      }

      // 4. Load Delivery Settings
      const { data: settings } = await client.from('store_settings').select('*');
      if (settings) {
        settings.forEach(item => {
          if (item.key === 'standard_shipping_fee' && document.getElementById('settingDeliveryFee')) {
            document.getElementById('settingDeliveryFee').value = item.value;
          }
          if (item.key === 'free_shipping_above' && document.getElementById('settingFreeShippingAbove')) {
            document.getElementById('settingFreeShippingAbove').value = item.value;
          }
          if (item.key === 'announcement_text' && document.getElementById('settingAnnouncement')) {
            document.getElementById('settingAnnouncement').value = item.value;
          }
        });
      }

      // 5. Recent orders
      const { data: recentOrders } = await client
        .from('orders')
        .select('*')
        .order('created_at', { ascending: false })
        .limit(5);

      const recentTbody = document.getElementById('recentOrdersTbody');
      if (recentTbody && recentOrders) {
        if (recentOrders.length === 0) {
          recentTbody.innerHTML = `<tr><td colspan="6" style="text-align:center; color: var(--text-muted); padding: 24px;">No customer orders placed yet.</td></tr>`;
        } else {
          recentTbody.innerHTML = recentOrders.map(o => `
            <tr>
              <td><strong>#${o.id.substring(0, 8)}</strong></td>
              <td>${o.shipping_name || 'Customer'}</td>
              <td>${o.shipping_phone || '-'}</td>
              <td>₹${Number(o.total_amount).toLocaleString('en-IN')}</td>
              <td><span class="pill pill-${o.status}">${o.status}</span></td>
              <td>${new Date(o.created_at).toLocaleDateString()}</td>
            </tr>
          `).join('');
        }
      }
    } catch (e) {
      console.error('Error loading dashboard stats:', e);
    }
  };

  // Save Store Delivery Settings
  window.saveStoreSettings = async function (event) {
    if (event) event.preventDefault();
    const client = getClient();
    if (!client) return;

    const deliveryFee = document.getElementById('settingDeliveryFee')?.value || '60';
    const freeAbove = document.getElementById('settingFreeShippingAbove')?.value || '999';
    const announcement = document.getElementById('settingAnnouncement')?.value || '';

    try {
      await client.from('store_settings').upsert([
        { key: 'standard_shipping_fee', value: deliveryFee, updated_at: new Date() },
        { key: 'free_shipping_above', value: freeAbove, updated_at: new Date() },
        { key: 'announcement_text', value: announcement, updated_at: new Date() }
      ]);
      window.showAdminToast('Store settings saved & applied live to website!');
    } catch (err) {
      console.error(err);
      window.showAdminToast('Failed to save settings: ' + err.message);
    }
  };

  // ==========================================
  // 2. ORDERS MANAGEMENT
  // ==========================================
  window.loadOrders = async function (filterStatus = 'all') {
    const client = getClient();
    if (!client) return;

    const tbody = document.getElementById('ordersTbody');
    if (!tbody) return;

    tbody.innerHTML = `<tr><td colspan="7" style="text-align:center; padding: 24px;">Loading orders…</td></tr>`;

    try {
      let query = client
        .from('orders')
        .select(`
          id,
          user_id,
          status,
          shipping_name,
          shipping_address,
          shipping_phone,
          subtotal_amount,
          total_amount,
          created_at,
          order_items (
            id,
            product_id,
            product_name_snapshot,
            unit_price,
            quantity,
            line_total
          )
        `)
        .order('created_at', { ascending: false });

      if (filterStatus !== 'all') {
        query = query.eq('status', filterStatus);
      }

      const { data: orders, error } = await query;
      if (error) throw error;

      if (!orders || orders.length === 0) {
        tbody.innerHTML = `<tr><td colspan="7" style="text-align:center; color: var(--text-muted); padding: 32px;">No orders found matching filter: ${filterStatus}</td></tr>`;
        return;
      }

      tbody.innerHTML = orders.map(o => `
        <tr>
          <td><strong>#${o.id.substring(0, 8)}</strong></td>
          <td>
            <strong>${o.shipping_name || 'Customer'}</strong><br>
            <span style="font-size: 11px; color: var(--text-muted);">${o.shipping_phone || ''}</span>
          </td>
          <td style="max-width: 220px; font-size: 12px; color: var(--text-muted);">${o.shipping_address || '-'}</td>
          <td>${o.order_items ? o.order_items.length : 0} items</td>
          <td><strong>₹${Number(o.total_amount).toLocaleString('en-IN')}</strong></td>
          <td>
            <select class="form-control" style="padding: 4px 8px; font-size: 12px; width: auto;" onchange="updateOrderStatus('${o.id}', this.value)">
              ${['pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled'].map(st => `
                <option value="${st}" ${o.status === st ? 'selected' : ''}>${st.toUpperCase()}</option>
              `).join('')}
            </select>
          </td>
          <td>
            <button class="btn-admin btn-ghost" style="padding: 4px 10px; font-size: 11px;" onclick="viewOrderDetails('${o.id}')">View Details</button>
          </td>
        </tr>
      `).join('');

      window._cachedOrders = orders;
    } catch (err) {
      console.error(err);
      tbody.innerHTML = `<tr><td colspan="7" style="text-align:center; color: var(--accent-red); padding: 24px;">Failed to load orders: ${err.message}</td></tr>`;
    }
  };

  window.updateOrderStatus = async function (orderId, newStatus) {
    const client = getClient();
    if (!client) return;

    try {
      const { error } = await client
        .from('orders')
        .update({ status: newStatus, updated_at: new Date() })
        .eq('id', orderId);

      if (error) throw error;

      // Log to order status history
      const { data: { user } } = await client.auth.getUser();
      await client.from('order_status_history').insert({
        order_id: orderId,
        status: newStatus,
        changed_by: user ? user.id : null,
        note: `Status advanced to ${newStatus} via Classic PWA Admin`
      });

      window.showAdminToast(`Order #${orderId.substring(0, 8)} status updated to ${newStatus.toUpperCase()}`);
    } catch (err) {
      console.error(err);
      window.showAdminToast(`Failed to update status: ${err.message}`);
    }
  };

  window.viewOrderDetails = function (orderId) {
    const order = (window._cachedOrders || []).find(o => o.id === orderId);
    if (!order) return;

    const modalBody = document.getElementById('orderDetailModalBody');
    if (!modalBody) return;

    modalBody.innerHTML = `
      <div style="margin-bottom: 20px;">
        <h3 style="font-family: var(--font-heading); font-size: 1.25rem;">Order #${order.id}</h3>
        <p style="font-size: 12px; color: var(--text-muted);">Placed on: ${new Date(order.created_at).toLocaleString()}</p>
      </div>

      <div style="background: var(--bg-surface); padding: 16px; border-radius: var(--radius-sm); margin-bottom: 20px;">
        <h4 style="font-size: 12px; text-transform: uppercase; color: var(--text-muted); margin-bottom: 8px;">Delivery Snapshot</h4>
        <p><strong>Recipient:</strong> ${order.shipping_name}</p>
        <p><strong>Address:</strong> ${order.shipping_address}</p>
        <p><strong>Phone:</strong> ${order.shipping_phone}</p>
      </div>

      <h4 style="font-size: 12px; text-transform: uppercase; color: var(--text-muted); margin-bottom: 8px;">Order Items</h4>
      <div class="table-wrap" style="margin-bottom: 20px;">
        <table class="admin-table">
          <thead>
            <tr>
              <th>Material Product</th>
              <th>Unit Price</th>
              <th>Qty</th>
              <th>Total</th>
            </tr>
          </thead>
          <tbody>
            ${(order.order_items || []).map(item => `
              <tr>
                <td>${item.product_name_snapshot}</td>
                <td>₹${Number(item.unit_price).toLocaleString('en-IN')}</td>
                <td>${item.quantity}</td>
                <td>₹${Number(item.line_total).toLocaleString('en-IN')}</td>
              </tr>
            `).join('')}
          </tbody>
        </table>
      </div>

      <div style="display: flex; justify-content: space-between; font-size: 1.15rem; font-weight: 700; border-top: 1px solid var(--border); padding-top: 16px;">
        <span>Total Amount:</span>
        <span>₹${Number(order.total_amount).toLocaleString('en-IN')}</span>
      </div>
    `;

    window.openAdminModal('orderDetailModal');
  };

  // ==========================================
  // 3. MATERIALS MANAGER (Classic_PRD.pdf)
  // ==========================================
  window.loadMaterials = async function () {
    const client = getClient();
    if (!client) return;

    const listContainer = document.getElementById('materialsList');
    if (!listContainer) return;

    try {
      const { data: materials, error } = await client
        .from('materials')
        .select('*')
        .order('name', { ascending: true });

      if (error) throw error;

      if (!materials || materials.length === 0) {
        listContainer.innerHTML = `<p style="color: var(--text-muted); padding: 16px;">No fabric materials found. Add one above!</p>`;
        return;
      }

      listContainer.innerHTML = materials.map(m => `
        <div style="display: flex; justify-content: space-between; align-items: center; padding: 12px 16px; background: var(--bg-surface); border: 1px solid var(--border); border-radius: var(--radius-sm); margin-bottom: 8px;">
          <div>
            <strong>${m.name}</strong>
            <span style="font-size: 11px; color: var(--text-muted); margin-left: 8px;">ID: ${m.id.substring(0, 8)}</span>
          </div>
          <button class="btn-admin btn-ghost btn-danger" style="padding: 4px 10px; font-size: 11px;" onclick="deleteMaterial('${m.id}', '${m.name}')">Delete</button>
        </div>
      `).join('');
    } catch (err) {
      console.error(err);
      listContainer.innerHTML = `<p style="color: var(--accent-red); padding: 16px;">Failed to load materials: ${err.message}</p>`;
    }
  };

  window.addMaterial = async function (event) {
    if (event) event.preventDefault();
    const client = getClient();
    if (!client) return;

    const input = document.getElementById('newMaterialName');
    const name = (input ? input.value : '').trim();
    if (!name) return;

    try {
      const { error } = await client.from('materials').insert({ name });
      if (error) throw error;

      input.value = '';
      window.showAdminToast(`Material "${name}" created successfully!`);
      window.loadMaterials();
    } catch (err) {
      console.error(err);
      window.showAdminToast(`Failed to add material: ${err.message}`);
    }
  };

  window.deleteMaterial = async function (id, name) {
    if (!confirm(`Are you sure you want to delete material "${name}"?`)) return;
    const client = getClient();
    if (!client) return;

    try {
      const { error } = await client.from('materials').delete().eq('id', id);
      if (error) throw error;

      window.showAdminToast(`Material "${name}" deleted.`);
      window.loadMaterials();
    } catch (err) {
      console.error(err);
      window.showAdminToast(`Failed to delete material: ${err.message}`);
    }
  };

  // ==========================================
  // 4. CATEGORIES, STYLES & PATTERNS MANAGER
  // ==========================================
  window.loadTaxonomy = async function () {
    const client = getClient();
    if (!client) return;

    const container = document.getElementById('taxonomyTree');
    if (!container) return;

    try {
      const { data: categories } = await client.from('categories').select('*').order('name');
      const { data: styles } = await client.from('styles').select('*').order('name');
      const { data: patterns } = await client.from('patterns').select('*').order('name');

      if (!categories || categories.length === 0) {
        container.innerHTML = `<p style="color: var(--text-muted); padding: 16px;">No categories created yet.</p>`;
        return;
      }

      container.innerHTML = categories.map(cat => {
        const catStyles = (styles || []).filter(s => s.category_id === cat.id);
        return `
          <div style="background: var(--bg-surface); border: 1px solid var(--border); border-radius: var(--radius-sm); padding: 16px; margin-bottom: 16px;">
            <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--border); padding-bottom: 10px; margin-bottom: 12px;">
              <div>
                <strong style="font-size: 1.1rem; color: #ffffff;">${cat.name}</strong>
                <span style="font-size: 11px; color: var(--text-muted); margin-left: 8px;">slug: ${cat.slug}</span>
              </div>
              <button class="btn-admin btn-ghost" style="padding: 3px 8px; font-size: 10px;" onclick="promptAddStyle('${cat.id}', '${cat.name}')">+ Add Style</button>
            </div>

            <div style="padding-left: 16px;">
              ${catStyles.length === 0 ? `<p style="font-size: 12px; color: var(--text-muted);">No styles under ${cat.name}.</p>` : catStyles.map(st => {
                const stylePatterns = (patterns || []).filter(p => p.style_id === st.id);
                return `
                  <div style="border-left: 2px solid var(--border); padding-left: 12px; margin-bottom: 12px;">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
                      <span style="font-weight: 600; font-size: 13px;">Style: ${st.name} <span style="font-size: 10px; color: var(--text-muted);">(${st.slug})</span></span>
                      <button class="btn-admin btn-ghost" style="padding: 2px 6px; font-size: 10px;" onclick="promptAddPattern('${st.id}', '${st.name}')">+ Add Pattern</button>
                    </div>
                    <div style="display: flex; flex-wrap: wrap; gap: 6px; padding-left: 12px;">
                      ${stylePatterns.length === 0 ? `<span style="font-size: 11px; color: var(--text-muted);">No patterns.</span>` : stylePatterns.map(p => `
                        <span style="background: var(--bg-card); border: 1px solid var(--border); padding: 2px 8px; border-radius: 4px; font-size: 11px;">
                          ${p.name}
                        </span>
                      `).join('')}
                    </div>
                  </div>
                `;
              }).join('')}
            </div>
          </div>
        `;
      }).join('');
    } catch (err) {
      console.error(err);
      container.innerHTML = `<p style="color: var(--accent-red); padding: 16px;">Failed to load taxonomy: ${err.message}</p>`;
    }
  };

  window.promptAddCategory = async function () {
    const name = prompt("Enter new Category Name (e.g. Men's):");
    if (!name || !name.trim()) return;
    const slug = name.trim().toLowerCase().replace(/[^a-z0-9]+/g, '-');

    const client = getClient();
    try {
      const { error } = await client.from('categories').insert({ name: name.trim(), slug });
      if (error) throw error;
      window.showAdminToast(`Category "${name}" created!`);
      window.loadTaxonomy();
    } catch (e) {
      window.showAdminToast('Error: ' + e.message);
    }
  };

  window.promptAddStyle = async function (categoryId, categoryName) {
    const name = prompt(`Enter new Style for ${categoryName} (e.g. Formal, Casual):`);
    if (!name || !name.trim()) return;
    const slug = name.trim().toLowerCase().replace(/[^a-z0-9]+/g, '-');

    const client = getClient();
    try {
      const { error } = await client.from('styles').insert({ category_id: categoryId, name: name.trim(), slug });
      if (error) throw error;
      window.showAdminToast(`Style "${name}" created!`);
      window.loadTaxonomy();
    } catch (e) {
      window.showAdminToast('Error: ' + e.message);
    }
  };

  window.promptAddPattern = async function (styleId, styleName) {
    const name = prompt(`Enter new Pattern for ${styleName} (e.g. Whites, Plain, Stripes, Checks, Prints):`);
    if (!name || !name.trim()) return;
    const slug = name.trim().toLowerCase().replace(/[^a-z0-9]+/g, '-');

    const client = getClient();
    try {
      const { error } = await client.from('patterns').insert({ style_id: styleId, name: name.trim(), slug });
      if (error) throw error;
      window.showAdminToast(`Pattern "${name}" created!`);
      window.loadTaxonomy();
    } catch (e) {
      window.showAdminToast('Error: ' + e.message);
    }
  };

  // ==========================================
  // 5. PRODUCTS CATALOG & SEARCH
  // ==========================================
  window.loadAllProducts = async function () {
    const client = getClient();
    if (!client) return;

    const tbody = document.getElementById('allProductsTbody');
    if (!tbody) return;

    tbody.innerHTML = `<tr><td colspan="7" style="text-align:center; padding: 24px;">Loading products…</td></tr>`;

    try {
      const { data: products, error } = await client
        .from('products')
        .select(`
          id,
          name,
          slug,
          price,
          stock_quantity,
          is_active,
          created_at,
          categories (name),
          styles (name),
          materials (name),
          product_images (image_url)
        `)
        .order('created_at', { ascending: false });

      if (error) throw error;

      if (!products || products.length === 0) {
        tbody.innerHTML = `<tr><td colspan="7" style="text-align:center; color: var(--text-muted); padding: 32px;">No products in catalog. Click "+ Add Product" to create your first fabric!</td></tr>`;
        return;
      }

      tbody.innerHTML = products.map(p => {
        const img = p.product_images && p.product_images.length > 0 ? p.product_images[0].image_url : 'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?auto=format&fit=crop&w=150&q=80';
        const imgCount = p.product_images ? p.product_images.length : 0;
        return `
          <tr>
            <td>
              <div style="position: relative; width: 48px;">
                <img src="${img}" style="width: 48px; height: 60px; object-fit: cover; border-radius: 4px; border: 1px solid var(--border);" alt="${p.name}">
                ${imgCount > 1 ? `<span style="position: absolute; bottom: 2px; right: 2px; background: rgba(0,0,0,0.8); color: #fff; font-size: 9px; padding: 1px 4px; border-radius: 2px;">+${imgCount - 1}</span>` : ''}
              </div>
            </td>
            <td>
              <strong>${p.name}</strong><br>
              <span style="font-size: 11px; color: var(--text-muted);">${p.slug}</span>
            </td>
            <td>${p.categories?.name || '-'} / ${p.styles?.name || '-'}</td>
            <td><span style="background: var(--bg-surface); border: 1px solid var(--border); padding: 2px 6px; border-radius: 4px; font-size: 11px;">${p.materials?.name || 'Fabric'}</span></td>
            <td><strong>₹${Number(p.price).toLocaleString('en-IN')}</strong></td>
            <td>
              <input type="number" value="${p.stock_quantity}" min="0" style="width: 70px; padding: 4px 6px; background: var(--bg-input); border: 1px solid var(--border); color: #fff; border-radius: 4px;" onchange="updateProductStock('${p.id}', this.value)">
            </td>
            <td>
              <button class="btn-admin ${p.is_active ? '' : 'btn-ghost'}" style="padding: 4px 8px; font-size: 11px;" onclick="toggleProductActive('${p.id}', ${!p.is_active})">
                ${p.is_active ? 'ACTIVE' : 'INACTIVE'}
              </button>
              <button class="btn-admin btn-ghost btn-danger" style="padding: 4px 8px; font-size: 11px; margin-left: 4px;" onclick="deleteProduct('${p.id}', '${p.name}')">
                DELETE
              </button>
            </td>
          </tr>
        `;
      }).join('');
    } catch (err) {
      console.error(err);
      tbody.innerHTML = `<tr><td colspan="7" style="text-align:center; color: var(--accent-red); padding: 24px;">Failed to load products: ${err.message}</td></tr>`;
    }
  };

  window.updateProductStock = async function (id, newStock) {
    const client = getClient();
    if (!client) return;

    try {
      const { error } = await client.from('products').update({ stock_quantity: parseInt(newStock, 10), updated_at: new Date() }).eq('id', id);
      if (error) throw error;
      window.showAdminToast('Stock updated successfully!');
    } catch (e) {
      window.showAdminToast('Error updating stock: ' + e.message);
    }
  };

  window.toggleProductActive = async function (id, newActive) {
    const client = getClient();
    if (!client) return;

    try {
      const { error } = await client.from('products').update({ is_active: newActive, updated_at: new Date() }).eq('id', id);
      if (error) throw error;
      window.showAdminToast(`Product marked ${newActive ? 'ACTIVE' : 'INACTIVE'}!`);
      window.loadAllProducts();
    } catch (e) {
      window.showAdminToast('Error: ' + e.message);
    }
  };

  window.deleteProduct = async function (id, name) {
    if (!confirm(`Delete product "${name}" permanently?`)) return;
    const client = getClient();
    if (!client) return;

    try {
      const { error } = await client.from('products').delete().eq('id', id);
      if (error) throw error;
      window.showAdminToast(`Product "${name}" deleted.`);
      window.loadAllProducts();
    } catch (e) {
      window.showAdminToast('Error deleting product: ' + e.message);
    }
  };

  // ==========================================
  // 6. HERO BANNERS MANAGEMENT
  // ==========================================
  window.loadBanners = async function () {
    const client = getClient();
    if (!client) return;

    const list = document.getElementById('bannersList');
    if (!list) return;

    try {
      const { data: banners, error } = await client
        .from('hero_banners')
        .select('*')
        .order('display_order', { ascending: true });

      if (error) throw error;

      if (!banners || banners.length === 0) {
        list.innerHTML = `<p style="color: var(--text-muted); padding: 16px;">No hero banners configured. Add a new banner above.</p>`;
        return;
      }

      list.innerHTML = banners.map(b => `
        <div style="display: flex; gap: 16px; align-items: center; background: var(--bg-surface); border: 1px solid var(--border); border-radius: var(--radius-sm); padding: 16px; margin-bottom: 12px; flex-wrap: wrap;">
          <img src="${b.image_url}" style="width: 140px; height: 80px; object-fit: cover; border-radius: 4px; border: 1px solid var(--border);">
          <div style="flex: 1; min-width: 220px;">
            <strong style="font-size: 1.1rem; color: #ffffff;">${b.title}</strong>
            <p style="font-size: 12px; color: var(--text-muted);">${b.subtitle || 'No subtitle'}</p>
            <p style="font-size: 11px; color: #60a5fa; margin-top: 4px;">Link: ${b.link_url}</p>
          </div>
          <div style="display: flex; gap: 8px;">
            <button class="btn-admin ${b.is_active ? '' : 'btn-ghost'}" style="padding: 6px 10px; font-size: 11px;" onclick="toggleBannerActive('${b.id}', ${!b.is_active})">
              ${b.is_active ? 'ACTIVE' : 'HIDDEN'}
            </button>
            <button class="btn-admin btn-ghost btn-danger" style="padding: 6px 10px; font-size: 11px;" onclick="deleteBanner('${b.id}')">
              DELETE
            </button>
          </div>
        </div>
      `).join('');
    } catch (e) {
      console.error(e);
      list.innerHTML = `<p style="color: var(--accent-red); padding: 16px;">Failed to load banners: ${e.message}</p>`;
    }
  };

  window.toggleBannerActive = async function (id, newActive) {
    const client = getClient();
    if (!client) return;

    try {
      const { error } = await client.from('hero_banners').update({ is_active: newActive }).eq('id', id);
      if (error) throw error;
      window.showAdminToast('Banner visibility updated!');
      window.loadBanners();
    } catch (e) {
      window.showAdminToast('Error: ' + e.message);
    }
  };

  window.deleteBanner = async function (id) {
    if (!confirm('Delete this banner?')) return;
    const client = getClient();
    if (!client) return;

    try {
      const { error } = await client.from('hero_banners').delete().eq('id', id);
      if (error) throw error;
      window.showAdminToast('Banner removed.');
      window.loadBanners();
    } catch (e) {
      window.showAdminToast('Error: ' + e.message);
    }
  };

  window.addNewBanner = async function (event) {
    if (event) event.preventDefault();
    const client = getClient();
    if (!client) return;

    const title = document.getElementById('bannerTitle').value;
    const subtitle = document.getElementById('bannerSubtitle').value;
    const imageUrl = document.getElementById('bannerImageUrl').value;
    const linkUrl = document.getElementById('bannerLinkUrl').value || '/pages/listing.html';
    const order = parseInt(document.getElementById('bannerOrder').value, 10) || 1;

    try {
      const { error } = await client.from('hero_banners').insert({
        title,
        subtitle,
        image_url: imageUrl,
        link_url: linkUrl,
        display_order: order,
        is_active: true
      });

      if (error) throw error;
      window.showAdminToast('New hero banner published to website!');
      document.getElementById('bannerForm').reset();
      window.loadBanners();
    } catch (e) {
      window.showAdminToast('Error publishing banner: ' + e.message);
    }
  };

  // ==========================================
  // 7. USERS / CUSTOMER PROFILES
  // ==========================================
  window.loadCustomerUsers = async function () {
    const client = getClient();
    if (!client) return;

    const tbody = document.getElementById('usersTbody');
    if (!tbody) return;

    tbody.innerHTML = `<tr><td colspan="5" style="text-align:center; padding: 24px;">Loading customer accounts…</td></tr>`;

    try {
      const { data: profiles, error } = await client
        .from('profiles')
        .select('*')
        .order('created_at', { ascending: false });

      if (error) throw error;

      if (!profiles || profiles.length === 0) {
        tbody.innerHTML = `<tr><td colspan="5" style="text-align:center; color: var(--text-muted); padding: 24px;">No registered profiles found.</td></tr>`;
        return;
      }

      tbody.innerHTML = profiles.map(p => `
        <tr>
          <td><strong>${p.name || 'Unnamed Customer'}</strong></td>
          <td>${p.phone || '-'}</td>
          <td style="max-width: 250px; font-size: 12px; color: var(--text-muted);">${p.address || '-'}</td>
          <td>
            <span class="pill ${p.is_admin ? 'pill-delivered' : 'pill-confirmed'}">
              ${p.is_admin ? 'ADMIN' : 'CUSTOMER'}
            </span>
          </td>
          <td>${new Date(p.created_at).toLocaleDateString()}</td>
        </tr>
      `).join('');
    } catch (e) {
      tbody.innerHTML = `<tr><td colspan="5" style="text-align:center; color: var(--accent-red); padding: 24px;">Error loading profiles: ${e.message}</td></tr>`;
    }
  };

})();
