.class public Li0/m;
.super Ljava/lang/Object;
.source "SourceFile"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Li0/m$b;
    }
.end annotation


# instance fields
.field public final a:Lj0/k;

.field public final b:Landroid/content/pm/PackageManager;

.field private c:Li0/m$b;

.field public final d:Lj0/k$c;


# direct methods
.method public constructor <init>(Lx/a;Landroid/content/pm/PackageManager;)V
    .locals 3

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    new-instance v0, Li0/m$a;

    invoke-direct {v0, p0}, Li0/m$a;-><init>(Li0/m;)V

    iput-object v0, p0, Li0/m;->d:Lj0/k$c;

    iput-object p2, p0, Li0/m;->b:Landroid/content/pm/PackageManager;

    new-instance p2, Lj0/k;

    sget-object v1, Lj0/r;->b:Lj0/r;

    const-string v2, "flutter/processtext"

    invoke-direct {p2, p1, v2, v1}, Lj0/k;-><init>(Lj0/c;Ljava/lang/String;Lj0/l;)V

    iput-object p2, p0, Li0/m;->a:Lj0/k;

    invoke-virtual {p2, v0}, Lj0/k;->e(Lj0/k$c;)V

    return-void
.end method

.method static synthetic a(Li0/m;)Li0/m$b;
    .locals 0

    iget-object p0, p0, Li0/m;->c:Li0/m$b;

    return-object p0
.end method


# virtual methods
.method public b(Li0/m$b;)V
    .locals 0

    iput-object p1, p0, Li0/m;->c:Li0/m$b;

    return-void
.end method
