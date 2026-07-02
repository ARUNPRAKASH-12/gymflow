import React from 'react';

export default function StatCard({ title, value, icon: Icon, color = 'primary', subtitle, onClick }) {
  const colorMap = {
    primary: 'bg-primary-500/10 text-primary-500',
    secondary: 'bg-secondary-500/10 text-secondary-500',
    success: 'bg-green-500/10 text-green-500',
    warning: 'bg-yellow-500/10 text-yellow-500',
    danger: 'bg-red-500/10 text-red-500',
    info: 'bg-blue-500/10 text-blue-500',
  };

  return (
    <div
      className="card cursor-pointer hover:border-dark-500 transition-colors"
      onClick={onClick}
    >
      <div className="flex items-center justify-between mb-4">
        <div className={`stat-icon ${colorMap[color] || colorMap.primary}`}>
          {Icon && <Icon size={22} />}
        </div>
        {subtitle && (
          <span className="text-xs text-dark-400">{subtitle}</span>
        )}
      </div>
      <p className="text-2xl font-bold text-white mb-1">{value}</p>
      <p className="text-sm text-dark-400">{title}</p>
    </div>
  );
}
