import Link from 'next/link';

const products = [
  ['QuoteRecover', 'Lead recovery, follow-ups, and quote conversion.', '/quoterecover'],
  ['TenderBrief', 'Curated Singapore tender intelligence and digests.', '/tenderbrief'],
  ['OpsKit', 'Tasks, customers, and repeatable service workflows.', '/opskit'],
];

export default function Home() {
  return <main style={{ maxWidth: 960, margin: '0 auto', padding: 40, fontFamily: 'system-ui' }}>
    <p style={{ color: '#64748b', fontWeight: 700 }}>SINGAPORE SME GROWTH PLATFORM</p>
    <h1>One operating system for three practical businesses.</h1>
    <p>Production platform foundation: accounts, organizations, product entitlements, and tenant-isolated data.</p>
    <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit,minmax(220px,1fr))', gap: 16, marginTop: 28 }}>
      {products.map(([name, description, href]) => <Link key={href} href={href} style={{ border: '1px solid #ddd', borderRadius: 12, padding: 18, textDecoration: 'none', color: 'inherit' }}><h2>{name}</h2><p>{description}</p><b>Open workspace →</b></Link>)}
    </div>
  </main>;
}
