.class public final synthetic Lu/f;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Ljava/lang/Runnable;


# instance fields
.field public final synthetic d:Lu/i;

.field public final synthetic e:Ljava/lang/String;

.field public final synthetic f:Ljava/lang/Object;


# direct methods
.method public synthetic constructor <init>(Lu/i;Ljava/lang/String;Ljava/lang/Object;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lu/f;->d:Lu/i;

    iput-object p2, p0, Lu/f;->e:Ljava/lang/String;

    iput-object p3, p0, Lu/f;->f:Ljava/lang/Object;

    return-void
.end method


# virtual methods
.method public final run()V
    .locals 3

    iget-object v0, p0, Lu/f;->d:Lu/i;

    iget-object v1, p0, Lu/f;->e:Ljava/lang/String;

    iget-object v2, p0, Lu/f;->f:Ljava/lang/Object;

    invoke-static {v0, v1, v2}, Lu/i;->j(Lu/i;Ljava/lang/String;Ljava/lang/Object;)V

    return-void
.end method
