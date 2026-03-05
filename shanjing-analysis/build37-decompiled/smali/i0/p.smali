.class public Li0/p;
.super Ljava/lang/Object;
.source "SourceFile"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Li0/p$b;
    }
.end annotation


# instance fields
.field public final a:Lj0/k;

.field private b:Li0/p$b;

.field public final c:Lj0/k$c;


# direct methods
.method public constructor <init>(Lx/a;)V
    .locals 4

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    new-instance v0, Li0/p$a;

    invoke-direct {v0, p0}, Li0/p$a;-><init>(Li0/p;)V

    iput-object v0, p0, Li0/p;->c:Lj0/k$c;

    new-instance v1, Lj0/k;

    sget-object v2, Lj0/r;->b:Lj0/r;

    const-string v3, "flutter/spellcheck"

    invoke-direct {v1, p1, v3, v2}, Lj0/k;-><init>(Lj0/c;Ljava/lang/String;Lj0/l;)V

    iput-object v1, p0, Li0/p;->a:Lj0/k;

    invoke-virtual {v1, v0}, Lj0/k;->e(Lj0/k$c;)V

    return-void
.end method

.method static synthetic a(Li0/p;)Li0/p$b;
    .locals 0

    iget-object p0, p0, Li0/p;->b:Li0/p$b;

    return-object p0
.end method


# virtual methods
.method public b(Li0/p$b;)V
    .locals 0

    iput-object p1, p0, Li0/p;->b:Li0/p$b;

    return-void
.end method
